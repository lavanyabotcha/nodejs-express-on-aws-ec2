variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable instance_type {
  description = "EC2 instance type that will be launched"
  default     = "t2.micro"
}

variable "env" {
  description = "Depolyment environment"
  default     = "dev"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "develop"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "lavanyabotcha"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "nodejs-express-on-aws-ec2"
}
