variable "project_name" {
  type    = string
  default = "sample"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
<<<<<<< HEAD
  default = "ap-south-1"
=======
  default = "us-east-1"
>>>>>>> 5ae2a26 (new)
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

<<<<<<< HEAD
=======
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

>>>>>>> 5ae2a26 (new)
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
<<<<<<< HEAD
}
=======
}

variable "alert_email" {
  type        = string
  description = "Email to notify when the app goes down"
}

variable "alert_phone" {
  type        = string
  description = "Optional phone number (E.164 format e.g. +91XXXXXXXXXX) for SMS alerts"
  default     = ""
}
>>>>>>> 5ae2a26 (new)
