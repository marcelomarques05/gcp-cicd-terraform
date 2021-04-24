# GCP CI/CD with Cloud Build, Composer and Dataflow

Terraform Code to Create a GCP CICD Project for Data Processing

## First Steps

- Create a folder in your Org and get the ID

```shell
gcloud resource-manager folders list - organization=<Your Org ID>
```

- Update the terraform.tfvars (copy or rename the terraform.tfvars.example) with the requested values.
  