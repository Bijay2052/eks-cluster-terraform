provider "aws" {
  region  = var.region
  profile = "test-lf-aws" #profile for this aws keys defined in ~/.aws/credentials(eg. default)
}

