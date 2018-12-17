terraform {
    backend "s3" {
        bucket = "terraform-state-datastore-hlechuga"
        key = "staging/databases/mysql.tfstate"
        region = "ap-southeast-1"
    }
}