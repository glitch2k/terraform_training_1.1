###--------the following variables will be defined:
  #-------- vpc cidr_block
  #-------- subnet x2 cidr_block
  #-------- ec2 instance x2:
    #-------- ami
    #-------- instance_type
    #-------- key_name
  #-------- gneneral purpose variables
    #-------- quad_0_ipv4
    #-------- quad_0_ipv6
    #-------- aws_access_key
    #-------- aws_secret_key

  #-------- vpc cidr_block
  # changing the value of this variable will affect the subnet resource cidr_block
  # if changes to the vpd cidr_block is made, the appropriate subnet range must be
  # ... changed for the cidr_block of the subnet resource

  # this value will be overridden with value from vsf.tfvars
  variable "vpc_cidr_block" {
    default = "172.46.0.0/16"
  }


  #-------- subnet x2 cidr_block
  # this value will be overridden with values from vsf.tfvars
  variable "pblc_sbnt_cidr_block" {
    default = "172.46.1.0/24"
  }

  variable "prvt_sbnt_cidr_block" {
    default = "172.46.2.0/24"
  }


  #-------- ec2 instance x2:
  #-------- ami
  # the value for this variable will be provided by the vsf.tfvars
  variable "ami" {}

  #-------- instance_type
  variable "instance_type" {
    default = "t2.medium"
  }

  #-------- key_name
  # the value for this variable will be provided by the vsf.tfvars
  variable "key_name" {}


  #-------- gneneral purpose variables
  #-------- quad_0_ipv4
  variable "quad_0_ipv4" {
    default = "0.0.0.0/0"
  }
  
  #-------- quad_0_ipv6
  variable "quad_0_ipv6" {
    default = "::/0"
  }
