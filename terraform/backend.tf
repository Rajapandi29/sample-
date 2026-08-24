terraform {
  backend "s3" {
    bucket = "my-terraformstate-18-8"
    key    = "https://my-terraformstate-18-8.s3.us-east-1.amazonaws.com/buckets/"
    region = "us-east-1"
    encrypt = true

  }
}
