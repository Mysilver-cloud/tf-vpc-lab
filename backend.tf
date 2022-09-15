terraform {
  backend "s3" {
    bucket = "ta-terraform-tfstates-2965-7290-6806"
    key    = "sprint2/week2/training-terraform/terraform.tfstates"
  }
}