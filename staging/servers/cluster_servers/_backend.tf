terraform {
    backend "s3" {
        bucket = "terraform-state-datastore-hlechuga"
        key    = "staging/servers/cluster_servers.tfstate"
        region = "ap-southeast-1"
    }
}
