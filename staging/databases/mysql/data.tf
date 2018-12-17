data "terraform_remote_state" "mysql" {
    backend = "s3"
    
    config {
        bucket = "terraform-state-datastore-hlechuga"
        key = "staging/databases/mysql.tfstate"
        region = "ap-southeast-1"
    }
    
}