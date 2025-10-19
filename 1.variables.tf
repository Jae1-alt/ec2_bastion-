variable "my_ip" {
  type        = string
  description = "IP address for SSH access."
  default     = "0.0.0.0/0"
}

variable "my_ip_rdp" {
  type        = string
  description = "IP address for RDP access."
  default     = "0.0.0.0/0"
}

# i took this frmo a previous project, will adjust soon
variable "user_data_script" {
  description = "This 'key:value' pair houses the name of the scripts to be used in the 'user-data' section for each instance, scripts pair with subnets."
  type        = map(string)
  default = {
    "script" = "user_a.sh"
    "script" = "user_a.sh"
  }
}

# every region other than you defualt region you intended to create a VPC, must have an associated with region/ provider declared
variable "vpc_info" {
  type = map(object({
    vpc_region = string
    vpc_name   = string
    vpc_cidr   = string
  }))

  description = "The CIDR range for the VPC"

  default = {
    "1st_vpc" = {
      vpc_region = "us-east-1"
      vpc_name   = "terraform-made-1"
      vpc_cidr   = "10.70.0.0/16"
    }
    # work in progress
    # "2nd_vpc" = {
    #   vpc_region = "us-west-1"
    #   vpc_name   = "test2"
    #   vpc_cidr   = "10.71.0.0/16"
    # }
  }

}

variable "public_subnets" {
  description = "Defines the number of subnets. The 'key : value' pair in the this variable will be used to create the subnets, number of subnets(based on the number of 'key:value' pairs, and the 'value' in the pair will be used to create the associeted subnet(s))"
  type = map(object({
    subnet_name      = string
    subnet_cidr_mask = number
  }))
  default = {
    "1st_subnet" = {
      subnet_name      = "subnet a"
      subnet_cidr_mask = 1
    }
  }
}

variable "private_subnets" {
  description = "Defines the number of subnets. The 'key : value' pair in the this variable will be used to create the subnets, number of subnets(based on the number of 'key:value' pairs, and the 'value' in the pair will be used to create the associeted subnet(s))"
  type = map(object({
    subnet_name      = string
    subnet_cidr_mask = number
    script           = string
    az              = number
  }))
  default = {
    "1st_private_subnet" = {
      subnet_name      = "subnet a"
      subnet_cidr_mask = 11
      script           = "user_a.sh"
      az = 0 # index number to chose AZ from list of choices
    }
    "2nd_private_subnet" = {
      subnet_name      = "subnet a"
      subnet_cidr_mask = 12
      script           = "user_b.sh"
      az = 1 # index number to chose AZ from list of choices
    }
    "3rd_private_subnet" = {
      subnet_name      = "subnet a"
      subnet_cidr_mask = 13
      script           = "user_c.sh"
      az = 2 # index number to chose AZ from list of choices
    }
  }
}

# this is will act a combination resuorce for vpcs and subnets forme to use later in the code. 
# The key to how this works is princple of the Catersian Product, think multiplying sets.
locals {
  vpc_subnet_combination = {
    for pair in setproduct(keys(var.vpc_info), keys(var.public_subnets)) :

    "${pair[0]}-${pair[1]}" => {
      vpc_key     = pair[0]
      subnet_key  = pair[1]
      vpc_region  = var.vpc_info[pair[0]].vpc_region
      vpc_data    = var.vpc_info[pair[0]]
      subnet_data = var.public_subnets[pair[1]]
      subnet_cidr = cidrsubnet(var.vpc_info[pair[0]].vpc_cidr, 8, var.public_subnets[pair[1]].subnet_cidr_mask)
    }
  }
}

# functiosn similar to the abve block, but is written for private subnets.
locals {
  vpc_private_subnet_combination = {
    for pair in setproduct(keys(var.vpc_info), keys(var.private_subnets)) :

    "${pair[0]}-${pair[1]}" => {
      vpc_key     = pair[0]
      subnet_key  = pair[1]
      vpc_region  = var.vpc_info[pair[0]].vpc_region
      vpc_data    = var.vpc_info[pair[0]]
      script      = var.private_subnets[pair[1]].script
      az      = var.private_subnets[pair[1]].az
      subnet_data = var.private_subnets[pair[1]]
      subnet_cidr = cidrsubnet(var.vpc_info[pair[0]].vpc_cidr, 8, var.private_subnets[pair[1]].subnet_cidr_mask)
    }
  }
}


locals {
  service_name     = "test vpc"
  Owner            = "jae"
  Environment      = "testing"
  service_name_igw = "test igw"
}

locals {
  vpc_tags = {
    for key, vpc in var.vpc_info :
    key => {
      Name         = vpc.vpc_name
      Service_name = local.service_name
      Owner        = local.Owner
      Environment  = local.Environment
    }
  }

  igw_tags = {
    for key, vpc in var.vpc_info :
    key => {
      Name         = "${vpc.vpc_name}-igw"
      Service_name = local.service_name_igw
      Owner        = local.Owner
      Environment  = local.Environment
    }
  }
}
