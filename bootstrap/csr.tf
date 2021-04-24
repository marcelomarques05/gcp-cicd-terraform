/******************************************
  Create Cloud Source Repos
*******************************************/

resource "google_sourcerepo_repository" "gcp_repo" {
  project = module.cloudbuild_project.project_id
  name    = var.cloud_source_repos
}