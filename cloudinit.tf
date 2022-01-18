#Define the init.cfg commands,
#add specific commands for adding user, groups etc in init.cfg

data "template_file" "init-script-ec2" {
  template = "${file("scripts/init-ec2.cfg")}"
}

data "template_cloudinit_config" "cloudinit-ec2" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init-ec2.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.init-script-ec2.rendered}"
  }
}
