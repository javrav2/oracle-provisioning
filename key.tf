resource "aws_key_pair" "ec2keypair" {
  key_name   = "${var.path_to_private_key}"
  public_key = "${file("${var.path_to_public_key}")}"
}
