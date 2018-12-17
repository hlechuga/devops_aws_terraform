provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_s3_bucket" "terraform-states" {
    bucket = "terraform-state-datastore-hlechuga"
    
    versioning {
        enabled = true
    }
    
    lifecycle {
        prevent_destroy = true
    }
}

output "s3_address" {
  value = "${aws_s3_bucket.terraform-states.address}"
}

output "s3_port" {
  value = "${aws_s3_bucket.terraform-states.port}"
}
