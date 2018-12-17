backend_bucket      = "terraform-state-datastore-hlechuga"
backend_key         = "staging/servers/cluster_servers.tfstate"

aws_region          = "ap-southeast-1"

this = "harrold"
cidr_block = "10.0.0.0/16"

ec2_instance_image  = "ami-0c88c9d4475a247f4"
server_http_port    = 9999
server_ssh_port     = 22