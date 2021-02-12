module "us-east-1" {
  source = "./us-east"
  providers = {
    aws = "aws"
  }
}
module "eu-west-1" {
  source = "./us-east"
  providers = {
    aws = "aws.eu-west-1"
  }
}