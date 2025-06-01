resource "aws_key_pair" "corp-key" {
  key_name   = "corp-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeUa5PV8ZtnpxxWqs6G3fYT3zEAs6QTaLGgRSCTDR++ dmrxt@lilglocc"
}

resource "aws_vpc" "corp-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "corp-vpc"
  }
}


resource "aws_subnet" "corp-sb" {
  vpc_id     = aws_vpc.corp-vpc.id 
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "corp-sb"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.corp-webserver.id
  
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.corp-vpc.id

  tags = {
    Name = "corp-igw"
  }
}

resource "aws_route_table" "corp-rt" {
  vpc_id = aws_vpc.corp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "corp-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.corp-sb.id
  route_table_id = aws_route_table.corp-rt.id
}

resource "aws_security_group" "allow_con" {
  name        = "allow_con"
  description = "Allow con inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.corp-vpc.id

  tags = {
    Name = "allow_con "
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_con.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  
}

resource "aws_instance" "corp-webserver" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name = aws_key_pair.corp-key.key_name
  subnet_id = aws_subnet.corp-sb.id
  associate_public_ip_address = true
  security_groups = [ aws_security_group.allow_con.id ]

  tags = {
    Name = "Corp-webserver"
  }
} 

resource "aws_s3_bucket" "corp-s3" {
  bucket = "corp-dm-bk"

  tags = {
    Name        = "corp-s3"
    Environment = "aws"
  }
}