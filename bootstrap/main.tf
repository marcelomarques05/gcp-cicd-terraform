/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  project_id       = var.project_id != "" ? var.project_id : format("%s-%s", var.project_prefix, "cloudbuild")
  gar_repo_name               = var.gar_repo_name != "" ? var.gar_repo_name : format("%s-%s", var.project_prefix, "tf-runners")
  cloudbuild_apis             = ["cloudbuild.googleapis.com", "sourcerepo.googleapis.com", "cloudkms.googleapis.com", "artifactregistry.googleapis.com", "composer.googleapis.com", "dataflow.googleapis.com", "container.googleapis.com", "appengine.googleapis.com"]
  impersonation_enabled_count = var.sa_enable_impersonation == true ? 1 : 0
  activate_apis               = distinct(concat(var.activate_apis, local.cloudbuild_apis))
  apply_branches_regex        = "^(${join("|", var.terraform_apply_branches)})$"
  gar_name                    = split("/", google_artifact_registry_repository.tf-image-repo.name)[length(split("/", google_artifact_registry_repository.tf-image-repo.name)) - 1]
}

resource "random_id" "suffix" {
  byte_length = 2
}

data "google_organization" "org" {
  organization = var.org_id
}
