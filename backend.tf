terraform {
  backend "gcs" {
    bucket = "shamiktestbucket"
    prefix = "terraform-gcp-infra/state"
  }
}