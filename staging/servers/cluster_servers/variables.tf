variable "this" {
    description = "Base name for infrastructure"
}
variable "cidr_block" {
    description = "Defines CIDR or the range of network"
}
variable "ec2_instance_image" {
  description = "EC2 instance image"
}
variable "server_http_port" {
  description = "Port use to send/receive HTTP data to server"
}
variable "server_ssh_port" {
    description = "Port used to send/receive SSH connection to server"
}
data "aws_availability_zones" "all" {}
