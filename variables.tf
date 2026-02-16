variable "project_name" {
    type = string
    description = "Name prefix for resources"
    default = "cv-static-site"
}

variable "aws_region" {
    type = string
    description = "AWS region"
    default = "eu-central-1"
}