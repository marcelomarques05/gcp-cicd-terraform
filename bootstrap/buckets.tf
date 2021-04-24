locals {
  bucket_list = toset(["composer-dataflow-source-test",
    "composer-input-test",
    "composer-ref-test",
    "composer-result-test",
    "dataflow-staging-test",
    "composer-dataflow-source-prod",
    "composer-input-prod",
    "composer-result-prod",
  "dataflow-staging-prod"])
}

resource "google_storage_bucket" "composer-dataflow-source-test" {
  for_each                    = local.bucket_list
  project                     = module.cloudbuild_project.project_id
  name                        = format("%s-%s", module.cloudbuild_project.project_id, each.value)
  location                    = "US"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  force_destroy = true
}