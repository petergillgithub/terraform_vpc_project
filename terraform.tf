terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }


backend "s3" {
    bucket = "terraform-remotestatefile-s3"
    dynamodb_table = "vpc-dynmodb"
    region = "eu-west-2"
  }

}
