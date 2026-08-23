variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "aws_region"        { type = string }
variable "vpc_id"            { type = string }
variable "subnet_ids"        { type = list(string) }
variable "security_group_id" { type = string }
variable "container_image"   { type = string }
variable "container_port"    { type = number, default = 3000 }
variable "cpu"                { type = number, default = 256 }
variable "memory"             { type = number, default = 512 }
variable "desired_count"      { type = number, default = 1 }
variable "target_group_arn"   { type = string }
