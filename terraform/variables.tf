variable "hardware" {
  type = string
  description = "hardware of ec2 server"
}

variable "sg" {
  type = string
  description = "security group"
}

variable "domain" {
  type = string
  description = "name of A record"
}

variable "zone" {
  type = string
  description = "aws hosted zone"
}

variable "ami" {
  type = string
  description = "amazon machine image"
}
