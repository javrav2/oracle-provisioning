output "gui-instance-ip" {
  value = "${aws_instance.ec2-instance.private_ip}"
}
output "gui-instance-id" {
  value = "${aws_instance.ec2-instance.id}"
}