terraform {
  backend "s3" {
    bucket = "my-terraformstate-18-8"
    key    = "./my-terraformstate-18-8/buckets/"
    region = "us-east-1"
    encrypt = true

  }
}
