output "cloudbuild_project_id" {
  description = "Project where CloudBuild configuration and terraform container image will reside."
  value       = module.cloudbuild_project.project_id
}

output "gcs_bucket_cloudbuild_artifacts" {
  description = "Bucket used to store Cloud/Build artefacts in CloudBuild project."
  value       = google_storage_bucket.cloudbuild_artifacts.name
}

output "csr_repos" {
  description = "List of Cloud Source Repos created by the module, linked to Cloud Build triggers."
  value       = google_sourcerepo_repository.gcp_repo
}

output "tf_runner_artifact_repo" {
  description = "GAR Repo created to store runner images"
  value       = google_artifact_registry_repository.tf-image-repo.name
}

output "composer_id" {
  description = "Cloud Composer Cluster ID"
  value       = google_composer_environment.composer-environment.id
}

output "composer_gke_cluster" {
  description = "Cloud Composer GKE Cluster Config"
  value       = google_composer_environment.composer-environment.config.0.gke_cluster
}

output "composer_dag_gcs_prefix" {
  description = "Cloud Composer DAG GCS"
  value       = google_composer_environment.composer-environment.config.0.dag_gcs_prefix
}