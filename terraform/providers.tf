terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider aws {
  region = "${var.region}"
  access_key = "<access_key>"
  secret_key = "<secret_key>"
}
