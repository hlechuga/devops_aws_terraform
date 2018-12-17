terraform {
    backend "s3" {
        bucket = "terraform-state-datastore-hlechuga"
        key = "staging/databases/postgres.tfstate"
        region = "ap-southeast-1"
    }
}