variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "default_zone" {
  description = "Default zone to create resources where applicable."
  type        = string
  default     = "us-central1-f"
}

variable "project_labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "cft"
}

variable "project_id" {
  description = "Custom project ID to use for project created."
  default     = ""
  type        = string
}

variable "activate_apis" {
  description = "List of APIs to enable in the Cloudbuild project."
  type        = list(string)

  default = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "container.googleapis.com"
  ]
}

variable "sa_enable_impersonation" {
  description = "Allow org_admins group to impersonate service account & enable APIs required."
  type        = bool
  default     = false
}

variable "storage_bucket_labels" {
  description = "Labels to apply to the storage bucket."
  type        = map(string)
  default     = {}
}

variable "create_cloud_source_repos" {
  description = "If shared Cloud Source Repos should be created."
  type        = bool
  default     = true
}

variable "cloud_source_repos" {
  description = "List of Cloud Source Repos to create with CloudBuild triggers."
  type        = string
  default     = "gcp-cicd"
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}

variable "terraform_version" {
  description = "Default terraform version."
  type        = string
  default     = "0.13.6"
}

variable "terraform_version_sha256sum" {
  description = "sha256sum for default terraform version."
  type        = string
  default     = "55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9"
}

variable "terraform_validator_release" {
  description = "Default terraform-validator release."
  type        = string
  default     = "2021-03-22"
}

variable "cloudbuild_plan_filename" {
  description = "Path and name of Cloud Build YAML definition used for terraform plan."
  type        = string
  default     = "build_deploy_test.yaml"
}

variable "cloudbuild_apply_filename" {
  description = "Path and name of Cloud Build YAML definition used for terraform apply."
  type        = string
  default     = "deploy_prod.yaml"
}

variable "terraform_apply_branches" {
  description = "List of git branches configured to run terraform apply Cloud Build trigger. All other branches will run plan by default."
  type        = list(string)

  default = [
    "master"
  ]
}

variable "gar_repo_name" {
  description = "Custom name to use for GAR repo."
  default     = ""
  type        = string
}

variable "random_suffix" {
  description = "Appends a 4 character random suffix to project ID and GCS bucket name."
  type        = bool
  default     = true
}

