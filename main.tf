# KEY PAIR
#####################

resource "aws_key_pair" "corp-key" {
  key_name   = "${var.name}-key"
  public_key = var.pub-key
}

# VPC
#####################

resource "aws_vpc" "corp-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.name}-vpc"
    Env = local.env
  }
}

# SUBNET
#####################


resource "aws_subnet" "corp-sb" {
  vpc_id     = aws_vpc.corp-vpc.id 
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.name}-sb"
    Env = local.env
  }
}

# ELASTIC IP
######################

resource "aws_eip" "lb" {
  instance = aws_instance.corp-webserver.id
  
}

# INTERNET GATEWAY
#######################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.corp-vpc.id

  tags = {
    Name = "${var.name}-igw"
    Env = local.env
  }
}

# ROUTE TABLE
##########################

resource "aws_route_table" "corp-rt" {
  vpc_id = aws_vpc.corp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "${var.name}-rt"
    Env = local.env
  }
}

# ROUTE TABLE ASSOCIATION
###########################

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.corp-sb.id
  route_table_id = aws_route_table.corp-rt.id
}

# SECURITY GROUP
############################

resource "aws_security_group" "allow_con" {
  name        = "allow_con"
  description = "Allow con inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.corp-vpc.id

  tags = {
    Name = "allow_con "
  }
}

# AWS INTSANCE
###########################

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.port-numbers.http
  ip_protocol       = "tcp"
  to_port           = var.port-numbers.http
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.port-numbers.ssh
  ip_protocol       = "tcp"
  to_port           = var.port-numbers.ssh
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  
}

resource "aws_instance" "corp-webserver" {
  ami           = var.image
  instance_type = var.instance-type
  key_name = aws_key_pair.corp-key.key_name
  subnet_id = aws_subnet.corp-sb.id
  associate_public_ip_address = true
  security_groups = [ aws_security_group.allow_con.id ]

  tags = {
    Name = "${var.name}-webserver"
    Env = local.env
  }
} 