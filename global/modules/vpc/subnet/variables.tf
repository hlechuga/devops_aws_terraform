variable "vpc_id" {
    description = "VPC name"
}

variable "cidr_block" {
    description = "CIDR block to be used by the VPC"
}

variable "availability_zone" {
    description = "Avalability zone to be used by VPC"
}

variable "map_public_ip_on_launch" {
    description = "If yes, instance will be assigned a public IP and will be publicly available"
}

variable "tag_name" {
    description = "Name tag fo the VPC"
}
