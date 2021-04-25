resource "random_id" "composer_random" {
  byte_length = 8
}

resource "google_composer_environment" "composer-environment" {
  name    = "composer-${random_id.composer_random.hex}"
  region  = var.default_region
  project = module.cloudbuild_project.project_id

  config {
    node_config {
      zone            = var.default_zone
      machine_type    = "n1-standard-1"
      network         = "default"
      subnetwork      = "default"
      service_account = "${module.cloudbuild_project.project_number}-compute@developer.gserviceaccount.com"
    }
    software_config {
      python_version = 2
      image_version = "composer-1.16.1-airflow-1.10.15"
      env_variables = {
        AIRFLOW_VAR_GCP_PROJECT                  = module.cloudbuild_project.project_id
        AIRFLOW_VAR_GCP_REGION                   = var.default_region
        AIRFLOW_VAR_GCP_ZONE                     = var.default_zone
        AIRFLOW_VAR_DATAFLOW_JAR_LOCATION_TEST   = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-dataflow-source-test"].url, "gs://")
        airflow_var_dataflow_jar_file_test       = "to_be_overriden"
        var_dataflow_jar_file_test               = "to_be_overriden"
        AIRFLOW_VAR_GCS_INPUT_BUCKET_TEST        = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-input-test"].url, "gs://")
        AIRFLOW_VAR_GCS_REF_BUCKET_TEST          = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-ref-test"].url, "gs://")
        AIRFLOW_VAR_GCS_OUTPUT_BUCKET_TEST       = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-result-test"].url, "gs://")
        AIRFLOW_VAR_DATAFLOW_STAGING_BUCKET_TEST = trimprefix(google_storage_bucket.composer-dataflow-source-test["dataflow-staging-test"].url, "gs://")
        AIRFLOW_VAR_DATAFLOW_JAR_LOCATION_PROD   = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-dataflow-source-prod"].url, "gs://")
        airflow_var_dataflow_jar_file_prod       = "to_be_overriden"
        var_dataflow_jar_file_prod               = "to_be_overriden"
        AIRFLOW_VAR_GCS_INPUT_BUCKET_PROD        = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-input-prod"].url, "gs://")
        AIRFLOW_VAR_GCS_OUTPUT_BUCKET_PROD       = trimprefix(google_storage_bucket.composer-dataflow-source-test["composer-result-prod"].url, "gs://")
        AIRFLOW_VAR_DATAFLOW_STAGING_BUCKET_PROD = trimprefix(google_storage_bucket.composer-dataflow-source-test["dataflow-staging-prod"].url, "gs://")
      }
    }
  }
}

resource "google_project_iam_member" "composer_admin" {
  project = module.cloudbuild_project.project_id
  role    = "roles/composer.admin"
  member  = "serviceAccount:${module.cloudbuild_project.project_number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "composer_worker" {
  project = module.cloudbuild_project.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${module.cloudbuild_project.project_number}@cloudbuild.gserviceaccount.com"
}