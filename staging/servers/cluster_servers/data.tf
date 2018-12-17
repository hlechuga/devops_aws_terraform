data "terraform_remote_state" "mysql" {
    backend = "s3"
    
    config {
        bucket = "terraform-state-datastore-hlechuga"
        key = "staging/databases/mysql.tfstate"
        region = "ap-southeast-1"
    }
    
}
data "template_file" "user_data" {
    template = "${file("files/userdata-nginx.sh")}"
    
    vars {
        server_port = "${var.server_http_port}"
        db_address = "${data.terraform_remote_state.mysql.address}"
        db_port = "${data.terraform_remote_state.mysql.port}"
    }
}
