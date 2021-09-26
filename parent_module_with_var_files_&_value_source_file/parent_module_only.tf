###--------the terraform init file will:
  #--------create vpc
  #--------create internet gateway (igw)
  #--------create subnet x2
  #--------create route table x2
  #--------associate route table to respective subnets x2
  #--------create elastic ip (eip)
  #--------create NAT gateway (ngw)
  #--------create security groups without rules
  #--------create security group rules
  #--------create ec2 instance x2 


provider "aws" {
  region = "us-east-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

###--------create vpc

resource "aws_vpc" "nebula_vpc" {
  cidr_block       = var.vpc_cidr_block
  # instance_tenancy = "${var.tenancy}"
  
  tags = {
    Name = "nebula_vpc"
  }
}

###--------create internet gateway (igw)

resource "aws_internet_gateway" "nebula_gw" {
  vpc_id = aws_vpc.nebula_vpc.id

  tags = {
    Name = "nebula_gw"
  }
}

###--------create subnet

resource "aws_subnet" "nebula_sbnt_01_pblc" {
  vpc_id     = aws_vpc.nebula_vpc.id
  cidr_block = var.pblc_sbnt_cidr_block

  tags = {
    Name = "nebula_sbnt_01_pblc"
  }
}

resource "aws_subnet" "nebula_sbnt_02_prvt" {
  vpc_id     = aws_vpc.nebula_vpc.id
  cidr_block = var.prvt_sbnt_cidr_block

  tags = {
    Name = "nebula_sbnt_02_prvt"
  }
}

###--------create route table (rt) x2

resource "aws_route_table" "pblc_rt" {
  vpc_id = aws_vpc.nebula_vpc.id

  route {
      cidr_block = var.quad_0_ipv4
      gateway_id = aws_internet_gateway.nebula_gw.id
    }
    
  tags = {
    Name = "pblc_rt"
  }
}

resource "aws_route_table" "prvt_rt" {
  vpc_id = aws_vpc.nebula_vpc.id

  route {
      cidr_block = var.quad_0_ipv4
      nat_gateway_id = aws_nat_gateway.nebula_ngw.id
    }
    
  tags = {
    Name = "prvt_rt"
  }
}

###--------associate route table to respective subnets x2

resource "aws_route_table_association" "add_to_pblc_sbnt" {
  subnet_id      = aws_subnet.nebula_sbnt_01_pblc.id
  route_table_id = aws_route_table.pblc_rt.id
}

resource "aws_route_table_association" "add_to_prvt_sbnt" {
  subnet_id      = aws_subnet.nebula_sbnt_02_prvt.id
  route_table_id = aws_route_table.prvt_rt.id
}

###--------create elastic ip (eip)

resource "aws_eip" "nebula_eip" {
  
  tags = {
    Name = "nebula_eip"
  }
}

###--------create NAT gateway (ngw)

resource "aws_nat_gateway" "nebula_ngw" {
  allocation_id = aws_eip.nebula_eip.id
  subnet_id     = aws_subnet.nebula_sbnt_01_pblc.id

  tags = {
    Name = "nebula_ngw"
  }
}

###--------create security groups without rules

resource "aws_security_group" "nebula_pblc_ec2_sg" {
  name        = "opnl_traffic_to_pblc_ec2"
  description = "Allow operational traffic to ec2 in public subnet"
  vpc_id      = aws_vpc.nebula_vpc.id


  tags = {
    Name = "nebula_pblc_ec2_sg"
  }
}

resource "aws_security_group" "nebula_prvt_ec2_sg" {
  name        = "opnl_traffic_to_prvt_ec2"
  description = "Allow operational traffic to ec2 in private subnet"
  vpc_id      = aws_vpc.nebula_vpc.id


  tags = {
    Name = "nebula_prvt_ec2_sg"
  }
}

resource "aws_security_group" "mgmt_access_to_ec2_sg" {
  name        = "mgmt_traffic_to_ec2"
  description = "Allow management traffic to ec2"
  vpc_id      = aws_vpc.nebula_vpc.id


  tags = {
    Name = "mgmt_access_to_ec2_sg"
  }
}

###--------create security group rules

#######--------create access to public ec2

resource "aws_security_group_rule" "opnl_http_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.nebula_pblc_ec2_sg.id
}

resource "aws_security_group_rule" "https_access" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.nebula_pblc_ec2_sg.id
}

#######--------create mgmt access to public ec2

resource "aws_security_group_rule" "mgmt_http_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.mgmt_access_to_ec2_sg.id
}

resource "aws_security_group_rule" "ssh_access_to_pblc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.mgmt_access_to_ec2_sg.id
}

#######--------create rules to access private ec2

resource "aws_security_group_rule" "ssh_access_to_prvt" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.nebula_prvt_ec2_sg.id
}

resource "aws_security_group_rule" "opnl_http_access_to_prvt" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.quad_0_ipv4]
  ipv6_cidr_blocks  = [var.quad_0_ipv6]
  security_group_id = aws_security_group.nebula_prvt_ec2_sg.id
}

###--------create ec2 instance

resource "aws_instance" "nebula_web" {
  count = 1
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.nebula_sbnt_01_pblc.id
  security_groups = [
      aws_security_group.nebula_pblc_ec2_sg.id,
      aws_security_group.mgmt_access_to_ec2_sg.id
  ]
  
  tags = {
    Name = "nebula_web"
  }
}

resource "aws_instance" "nebula_backend" {
  count = 1
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.nebula_sbnt_02_prvt.id
  security_groups = [
      aws_security_group.nebula_prvt_ec2_sg.id,
      aws_security_group.mgmt_access_to_ec2_sg.id
  ]
  
  tags = {
    Name = "nebula_backend"
  }
}