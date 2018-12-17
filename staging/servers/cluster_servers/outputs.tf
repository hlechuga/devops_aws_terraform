output "elb_dns_port" {
    value = "${aws_elb.load_balancer.dns_name}"
}

# output "out_internet_gateway" {
#   value = "${module.internet_gateway.id}"
# }
