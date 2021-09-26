###--------the following values for their respective variables will be defined:
  #-------- vpc cidr_block
  #-------- subnet x2 cidr_block
  #-------- ec2 instance 
    #-------- ami
    #-------- key_name


  #-------- vpc cidr_block value (this will over-ride the default value in the var.tf file
  vpc_cidr_block= "172.58.0.0/16"


  #-------- subnet x2 cidr_block values (this will over-ride the default value in the var.tf file
  pblc_sbnt_cidr_block = "172.58.1.0/24"

  prvt_sbnt_cidr_block = "172.58.2.0/24"


  #-------- ec2 instance 
  #-------- ami value (since this variable does not have a default value, this will be its value)
  ami = "ami-00399ec92321828f5"
  
  #-------- key_name value (since this variable does not have a default value, this will be its value)
  key_name = "terraform_training"
#   key_name = "terraform_training_02"