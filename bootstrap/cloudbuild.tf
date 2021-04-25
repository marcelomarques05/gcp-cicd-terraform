/******************************************
  Cloudbuild project
*******************************************/

module "cloudbuild_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 10.1.1"
  name                        = local.project_id
  random_project_id           = var.random_suffix
  disable_services_on_destroy = false
  default_service_account     = "keep"
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
  labels                      = var.project_labels
  auto_create_network         = true
}

resource "google_storage_bucket" "cloudbuild_artifacts" {
  project                     = module.cloudbuild_project.project_id
  name                        = format("%s-%s-%s", var.project_prefix, "cloudbuild-artifacts", random_id.suffix.hex)
  location                    = var.default_region
  labels                      = var.storage_bucket_labels
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/***********************************************
 Cloud Build - Master branch triggers
 ***********************************************/

resource "google_cloudbuild_trigger" "master_trigger" {
  project     = module.cloudbuild_project.project_id
  description = "${var.cloud_source_repos} - terraform apply."

  trigger_template {
    branch_name = local.apply_branches_regex
    repo_name   = var.cloud_source_repos
  }

  substitutions = {
    REPO_NAME                 = trimprefix(google_sourcerepo_repository.gcp_repo.id, "projects/${module.cloudbuild_project.project_id}/repos/")
    _DATAFLOW_JAR_BUCKET_TEST = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-dataflow-source-test"].url, "gs://")
    _DATAFLOW_JAR_FILE_LATEST = "latest.jar"
    _DATAFLOW_JAR_BUCKET_PROD = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-dataflow-source-prod"].url, "gs://")
    _COMPOSER_INPUT_BUCKET    = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-input-prod"].url, "gs://")
    _COMPOSER_DAG_BUCKET      = google_composer_environment.composer-environment.config.0.dag_gcs_prefix
    _COMPOSER_ENV_NAME        = google_composer_environment.composer-environment.name
    _COMPOSER_REGION          = var.default_region
    _COMPOSER_DAG_NAME_PROD   = "prod_word_count"
  }

  filename = var.cloudbuild_apply_filename
  depends_on = [
    google_sourcerepo_repository.gcp_repo,
  ]
}

/***********************************************
 Cloud Build - Non Master branch triggers
 ***********************************************/

resource "google_cloudbuild_trigger" "non_master_trigger" {
  project     = module.cloudbuild_project.project_id
  description = "${var.cloud_source_repos} - terraform plan."

  trigger_template {
    invert_regex = true
    branch_name  = local.apply_branches_regex
    repo_name    = var.cloud_source_repos
  }

  substitutions = {
    REPO_NAME               = trimprefix(google_sourcerepo_repository.gcp_repo.id, "projects/${module.cloudbuild_project.project_id}/repos/")
    _DATAFLOW_JAR_BUCKET    = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-dataflow-source-test"].url, "gs://")
    _COMPOSER_INPUT_BUCKET  = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-input-test"].url, "gs://")
    _COMPOSER_REF_BUCKET    = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-ref-test"].url, "gs://")
    _COMPOSER_DAG_BUCKET    = google_composer_environment.composer-environment.config.0.dag_gcs_prefix
    _COMPOSER_ENV_NAME      = google_composer_environment.composer-environment.name
    _COMPOSER_REGION        = var.default_region
    _COMPOSER_DAG_NAME_TEST = "test_word_count"
  }

  filename = var.cloudbuild_plan_filename
  depends_on = [
    google_sourcerepo_repository.gcp_repo,
  ]
}

/***********************************************
 Cloud Build - Terraform Image Repo
 ***********************************************/
resource "google_artifact_registry_repository" "tf-image-repo" {
  provider = google-beta
  project  = module.cloudbuild_project.project_id

  location      = var.default_region
  repository_id = local.gar_repo_name
  description   = "Docker repository for Terraform runner images used by Cloud Build"
  format        = "DOCKER"
}

/***********************************************
 Cloud Build - Terraform builder
 ***********************************************/

resource "null_resource" "cloudbuild_terraform_builder" {
  triggers = {
    project_id_cloudbuild_project = module.cloudbuild_project.project_id
    terraform_version_sha256sum   = var.terraform_version_sha256sum
    terraform_version             = var.terraform_version
    gar_name                      = local.gar_name
    gar_location                  = google_artifact_registry_repository.tf-image-repo.location
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud builds submit ${path.module}/cloudbuild_builder/ \
      --project ${module.cloudbuild_project.project_id} \
      --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
      --substitutions=_TERRAFORM_VERSION=${var.terraform_version},_TERRAFORM_VERSION_SHA256SUM=${var.terraform_version_sha256sum},_TERRAFORM_VALIDATOR_RELEASE=${var.terraform_validator_release},_REPOSITORY=${local.gar_name}
  EOT
  }
  depends_on = [
    google_artifact_registry_repository_iam_member.terraform-image-iam
  ]
}

/***********************************************
  Cloud Build - IAM
 ***********************************************/

resource "google_storage_bucket_iam_member" "cloudbuild_artifacts_iam" {
  bucket = google_storage_bucket.cloudbuild_artifacts.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.cloudbuild_project.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_artifact_registry_repository_iam_member" "terraform-image-iam" {
  provider = google-beta
  project  = module.cloudbuild_project.project_id

  location   = google_artifact_registry_repository.tf-image-repo.location
  repository = google_artifact_registry_repository.tf-image-repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${module.cloudbuild_project.project_number}@cloudbuild.gserviceaccount.com"
}