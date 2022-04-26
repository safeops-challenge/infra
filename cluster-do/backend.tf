terraform {
  backend "s3" {
    region                      = "us-east-2"
    bucket                      = "backend-safeops-challenge" 
    key                         = "terraform.tfstate"
  }
}
