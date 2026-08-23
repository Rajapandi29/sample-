terraform {
  backend "s3" {
    bucket = "my-terraformstate-18-8"
    key    = "my-terraformstate-18-8/buckets/"
    region = "us-east-1"
    encrypt = true

    # If you already created a DynamoDB table for state locking, keep this line.
    # If not, either create one or remove this line (Terraform >=1.9 can use
    # use_lockfile = true instead of DynamoDB).
    dynamodb_table = "terraform-lock-table"
  }
}
