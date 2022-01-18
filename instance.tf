# Oracle DB provisioning 
# Author		: Darryl Mendez 
# Date			: 08/05/2020
# Description	: Initial Revision - Create an Oracle Database 

resource "aws_instance" "ec2-instance" {
  ami           = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # the public SSH key
  key_name = "${aws_key_pair.ec2keypair.key_name}"

  # user data

  user_data = "${data.template_cloudinit_config.cloudinit-ec2.rendered}"


  provisioner "local-exec" {
    command = "echo ${aws_instance.ec2-instance.private_ip} >> ec2-private_ips.txt"
  }
  provisioner "file" {
    source      = "/data/oracle/deployment"
    destination = "/tmp"
  }
  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp"
  }


  connection {
    user        = "${var.instance_username}"
    host        = "${self.private_ip}"
    private_key = "${file("${var.path_to_private_key}")}"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/ec2.sh",
      "sudo /tmp/scripts/ec2.sh",
    ]
  }

  network_interface {
    network_interface_id  = "${var.primary_eni_id}"
    delete_on_termination = false
    device_index          = 0
  }


  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags = {
    "AV"               = "True"
    "Application Name" = "Automated Oracle Database Provisioning"
    "BAP ID"           = "N/A"
    "Backup"           = ""
    "DBA"              = "Darryl Mendez"
    "IT System Owner"  = "N/A"
    "Name"             = "Automated Oracle Database Provisioning"
    "Orphaned"         = "No"
    "Tech Lead"        = "Darryl Mendez"
  }

}

resource "null_resource" "oracle" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", aws_volume_attachment.ebs_att8.*.id)}"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.instance_username}"
      host        = "${aws_instance.ec2-instance.private_ip}"
      private_key = "${file("${var.path_to_private_key}")}"
    }
    inline = [
      "chmod +x /tmp/scripts/ebs.sh",
      "sudo /tmp/scripts/ebs.sh",
      "chmod +x /tmp/scripts/oracle.sh",
      "sudo /tmp/scripts/oracle.sh",
    ]
  }
}

