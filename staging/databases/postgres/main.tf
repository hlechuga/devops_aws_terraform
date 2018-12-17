provider "aws" {
    region = "ap-southeast-1"
}

module "mysql" {
    source = "../../../global/modules/databases/"
  
    db_name = "postgres-sample-database"
    db_engine = "postgres"
    db_allocated_storage = 10
    db_instance_class = "db.t2.micro"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
}