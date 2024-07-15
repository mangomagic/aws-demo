#
# Demo App - ACM Self Signed
#
# Inputs
#

variable "common_name" {

  type = string

  default = "example.com"
}

variable "organization" {

  type = string

  default = "Demo"
}

variable "validity_period_hours" {

  type = number

  default = 8766 # 1 year
}

variable "tags" {

  type = map(string)

  default = {}
}