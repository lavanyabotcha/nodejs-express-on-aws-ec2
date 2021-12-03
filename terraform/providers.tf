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
  access_key = "AKIAZONS4MQ6YK2L2MHK"
  secret_key = "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"
}
