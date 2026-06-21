terraform {
  backend "s3" {
    bucket = "bedrock-tfstate-alt-soe-025-3203-1781998443"
    key    = "project-bedrock/terraform.tfstate"
    region = "us-east-1"
  }
}
