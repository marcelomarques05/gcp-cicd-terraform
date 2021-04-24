# GCP CI/CD with Cloud Build, Composer and Dataflow

Terraform Code to Create a GCP CICD Project for Data Processing

To understand easily the purpose of this, you can read this:

<https://cloud.google.com/architecture/cicd-pipeline-for-data-processing#create_the_production_pipeline>

![Image](https://cloud.google.com/architecture/images/cicd-pipeline-for-data-processing-1-diagram-pipeline.svg)

## Execution

```shell
cd bootstrap
```

- Update the bootstrap/terraform.tfvars (copy or rename the terraform.tfvars.example) with the requested values.

```shell
terraform init
terraform apply
```

- Terraform will provide the project output you will need to clone the repository created

```shell
Outputs:

cloudbuild_project_id = <project_id>
csr_repos = {
  "name" = "gcp-mlops"
}
```

- Clone the repository (outside of this repo folder) and switch to any branch different from master

```shell
gcloud source repos clone gcp-mlops --project=<project_id>
cd gcp-mlops
git checkout -b plan
```

- Copy the files inside "source_code" to your cloned repo

```shell
cp -rf gcp-cicd-terraform/source_code/* gcp-mlops/
```

- Push to Cloud Source Repository

```shell
git add -A
git commit -m "First Commit to Plan"
git push --set-upstream origin plan
```

- Check the Cloud Build Job, Composer (AirFlow) and Dataflow! If everything works fine, commit to master branch and check if it works fine
