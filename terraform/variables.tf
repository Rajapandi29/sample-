variable "project_name" {
  type    = string
  default = "sample"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type = string

  default = "us-east-1"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "alert_email" {
  type        = string
  description = "Email to notify when the app goes down"
}

variable "alert_phone" {
  type        = string
  description = "Optional phone number for SMS alerts"
  default     = ""
}
