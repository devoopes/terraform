# variables.tf | Terraform VPC Variables

variable "infra_env" {
  type        = string
  description = "Environment short name"
}
variable "stack_name" {
  type        = string
  description = "Environment long name"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS Region"
  ## Note: This variable has to be hardset in main.tf.
  ## Manually change this if region is changed
  ## but it require an init with -backend-config and per env `.config` file so leaving alone for now.
  ## https://www.terraform.io/language/settings/backends/configuration
}

# Define VPC
variable "public_subnet_numbers" {
  type        = map(number)
  description = "Map of AZ to a number that should be used for public subnets"
  default = {
    "us-west-2a" = 1
    "us-west-2b" = 2
    "us-west-2c" = 3
  }
}

variable "private_subnet_numbers" {
  type        = map(number)
  description = "Map of AZ to a number that should be used for private subnets"
  default = {
    "us-west-2a" = 4
    "us-west-2b" = 5
    "us-west-2c" = 6
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Terrafrom IP Range"
  default     = "172.16.0.0/16"
}
