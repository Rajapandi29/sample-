terraform {
  backend "s3" {
    # This is your EXISTING state bucket (different from terraform-module-23-8,
    # which only stores reusable module zip files). Replace with your real state bucket name.
    bucket = "REPLACE_WITH_YOUR_STATE_BUCKET_NAME"
    key    = "sample-project/dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true

    # If you already created a DynamoDB table for state locking, keep this line.
    # If not, either create one or remove this line (Terraform >=1.9 can use
    # use_lockfile = true instead of DynamoDB).
    dynamodb_table = "terraform-lock-table"
  }
}
