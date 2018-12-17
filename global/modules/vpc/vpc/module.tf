resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr_block}"
    
    tags {
        Name = "${var.tag_name}"
    }
}