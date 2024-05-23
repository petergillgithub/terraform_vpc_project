vpc_cidr = "10.1.0.0/16"

common_tags = {
    "Name" = "Dev-VPC"
    "Company" = "Peter Technologies"
}

public_subnet_cidr = ["10.1.0.0/20","10.1.16.0/20"]

private_subnet_cidr = ["10.1.32.0/19","10.1.64.0/18"]