
##################################### VPC CREATION #########################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = "default"
  tags                 = merge(var.common_tags, { "Name" = "Demo-VPC" })
}


###################################### PUBLIC SUBNET #########################################################


resource "aws_subnet" "publicsubnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available_area.names[count.index]

  tags = merge(var.common_tags, { "Name" = "Public-Subnet - ${count.index + 1}" })
}

###################################### PRIVATE SUBNET #########################################################


resource "aws_subnet" "privatesubnet" {
  count      = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidr, count.index)

  availability_zone = data.aws_availability_zones.available_area.names[count.index]

  tags = merge(var.common_tags, { "Name" = "Private-Subnet - ${count.index + 1}" })
}


# ################################################## INTERNET-GATEWAY ###############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id


  tags = {
    "Name" = "IGW"
  }
}


##################################### PUBLIC ROUTE-TABLE ###########################################################
resource "aws_route_table" "public-rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.common_tags, {
    "Name" = "Public-RouteTable"
  })

}

######################################### PUBLIC ROUTE TABLE ASSOCIATION #################################################
resource "aws_route_table_association" "publicassociate" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.publicsubnet[*].id, count.index)
  route_table_id = aws_route_table.public-rt.id
}




############################################### ELASTIC IP #################################################################
resource "aws_eip" "elastic_ip" {
  count  = length(var.public_subnet_cidr)
  domain = "vpc"

  tags = {
    "Name" = "Elastic-Ip - ${count.index + 1}"
  }

}



############################################### NAT GATEWAY #################################################################
resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.public_subnet_cidr)
  allocation_id = element(aws_eip.elastic_ip[*].id, count.index)
  subnet_id     = element(aws_subnet.publicsubnet[*].id, count.index) ##aws_subnet.privatesubnets[count.index].id

  tags = {
    Name = "gw NAT ${count.index + 1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}



# ###################################################### PRIVATE ROUTE TABLE ####################################################
resource "aws_route_table" "private-rt" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat-gateway[*].id, count.index) ###aws_nat_gateway.natgateway[count.index].id=
  }
  tags = {
    "Name" : "Private-RT - ${count.index}"
  }

}

########################################## PRIVATE ROUTE TABLE ASSOCIATION #################################################

resource "aws_route_table_association" "privateassociate" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.privatesubnet[*].id, count.index)
  route_table_id = element(aws_route_table.private-rt[*].id, count.index) ###aws_subnet.privatesubnets[count.index].id
}