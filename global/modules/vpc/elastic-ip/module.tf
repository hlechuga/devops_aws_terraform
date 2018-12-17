resource "aws_eip" "my-eip" {
    vpc = true

    tags {
        Name = "${var.tag_name}"
    }
}