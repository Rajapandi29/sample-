<<<<<<< HEAD
 project_name         = "sample-"
=======
project_name         = "sample"
>>>>>>> 5ae2a26 (new)
environment          = "dev"
aws_region           = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
<<<<<<< HEAD
container_port       = 3000
=======
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
container_port       = 3000
cpu                  = 256
memory               = 512
desired_count        = 1

# CHANGE THESE to your real contact details
alert_email = "you@example.com"
alert_phone = ""
>>>>>>> 5ae2a26 (new)
