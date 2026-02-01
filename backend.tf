terraform {
  backend "s3" {
    bucket = "terraform-state-netflix-project"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}