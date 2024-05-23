variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true

}

variable "enable_dns_support" {
  type    = bool
  default = true

}

variable "common_tags" {
  type = map(string)

  default = {
    "Team" = "Dev"
  }

}

variable "public_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
  description = "Apple-Public-Subnet"

}

variable "private_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.64.0/18", "10.0.128.0/17"]
  description = "Apple-Private-Subnet"


}

