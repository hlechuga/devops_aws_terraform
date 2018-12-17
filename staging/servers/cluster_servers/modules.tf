# module "aws_vpc" {
#     source = "../../../global/modules/vpc/vpc/"
    
#     cidr_block = "${var.cidr_block}"
#     tag_name = "${var.this}-vpc"
# }
# module "internet_gateway" {
#   source = "../../../global/modules/vpc/internet-gateway/"
  
#   vpc_id = "${module.aws_vpc.id}"
#   tag_name = "${var.this}-igw"
# }
# module "elastic_ip" {
#   source = "../../../global/modules/vpc/elastic-ip/"
#   depends_on = ["aws_internet_gateway.my-igw"]
#   tag_name = "${var.this}-elastic-ip"
# }

# resource "aws_eip" "my-eip" {
#     vpc = true
#     depends_on = ["aws_internet_gateway.my-igw"]
    
#     tags {
#         Name = "${var.this}-elastic-ip"
#     }
# }
# module "nat_gateway" {
#     source = "../../../global/modules/vpc/nat-gateway/"
#     allocation_id = "${module.elastic_ip.id}"
#     subnet_id = "${module.public_subnet.id}"
#     tag_name = "${var.this}-nat-gateway"
#     # depends_on = ["module.internet_gateway.id"]
# }

# module "public_subnet" {
#     source = "../../../global/modules/vpc/subnet/"
  
#     vpc_id = "${module.aws_vpc.id}"
#     cidr_block = "${var.cidr_block}"
#     availability_zone = "${data.availability_zones.all.names[0]}"
#     map_public_ip_on_launch = true
#     tag_name = "Public"
# }

# module "public-route-table" {
#     source = "../../../global/modules/route-table/"
    
#     vpc_id = "${aws_vpc.my-vpc.id}"
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_internet_gateway.my-igw.id}"
#     tag_name = "${var.this}-public-route"
# }
# module "public-route-table-association" {
#     source = "../../../global/modules/route-table-association/"
    
#     subnet_id = "${module.public-subnet.id}"
#     route_table_id = "${module.public-route-table.id}"
# }
# module "private-subnet" {
#     source = "../../../global/modules/subnet/"
    
#     vpc_id = "${aws_vpc.my-vpc.id}"
#     cidr_block = "10.0.2.0/24"
#     availability_zone = "${data.aws_availability_zones.all.names[1]}"
#     map_public_ip_on_launch = false
#     tag_name = "${var.this}-Private"
# }