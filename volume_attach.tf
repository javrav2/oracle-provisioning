resource "aws_ebs_volume" "vol1" {
  availability_zone = "us-east-1a"
  size              = "16"
  encrypted         = "false"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "Swap Space"
    "Tech Lead"          = "Darryl Mendez"
  }
}

resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.vol1.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}



resource "aws_ebs_volume" "vol2" {
  availability_zone = "us-east-1a"
  size              = "300"
  encrypted         = "false"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "oradb1"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol1"
  ]
}

resource "aws_volume_attachment" "ebs_att2" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.vol2.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}


resource "aws_ebs_volume" "vol3" {
  availability_zone = "us-east-1a"
  size              = "5"
  encrypted         = "false"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "oralg1"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol2"
  ]
}

resource "aws_volume_attachment" "ebs_att3" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.vol3.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}


resource "aws_ebs_volume" "vol4" {
  availability_zone = "us-east-1a"
  size              = "5"
  encrypted         = "false"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "oralg2"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol3"
  ]
}

resource "aws_volume_attachment" "ebs_att4" {
  device_name = "/dev/sdi"
  volume_id   = "${aws_ebs_volume.vol4.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}


resource "aws_ebs_volume" "vol5" {
  availability_zone = "us-east-1a"
  size              = "50"
  encrypted         = "false"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "ora_backup_dd_nfs"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol4"
  ]
}

resource "aws_volume_attachment" "ebs_att5" {
  device_name = "/dev/sdj"
  volume_id   = "${aws_ebs_volume.vol5.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}


resource "aws_ebs_volume" "vol6" {
  availability_zone = "us-east-1a"
  size              = "100"
  encrypted         = "true"
  kms_key_id        = "arn:aws:kms:us-east-1:223348157960:key/47a6564a-6f4a-48ba-8933-1fcb99b293fc"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "orabin"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol5"
  ]
}

resource "aws_volume_attachment" "ebs_att6" {
  device_name = "/dev/sdk"
  volume_id   = "${aws_ebs_volume.vol6.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}

resource "aws_ebs_volume" "vol7" {
  availability_zone = "us-east-1a"
  size              = "200"
  encrypted         = "true"
  kms_key_id        = "arn:aws:kms:us-east-1:223348157960:key/47a6564a-6f4a-48ba-8933-1fcb99b293fc"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "orabck"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol6"
  ]
}

resource "aws_volume_attachment" "ebs_att7" {
  device_name = "/dev/sdl"
  volume_id   = "${aws_ebs_volume.vol7.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
}


resource "aws_ebs_volume" "vol8" {
  availability_zone = "us-east-1a"
  size              = "50"
  encrypted         = "true"
  kms_key_id        = "arn:aws:kms:us-east-1:223348157960:key/47a6564a-6f4a-48ba-8933-1fcb99b293fc"
  type              = "gp2"
  tags = {
    "Application Name"   = "Automated Oracle Database Provisioning"
    "BAP ID"             = ""
    "Backup"             = "TRUE"
    "DBA"                = "Darryl Mendez"
    "IT System Owner"    = ""
    "Name"               = ""
    "Orphaned"           = "No"
    "Purpose"            = "oraarc"
    "Tech Lead"          = "Darryl Mendez"
  }
  depends_on = [
    "aws_ebs_volume.vol7"
  ]

}


resource "aws_volume_attachment" "ebs_att8" {
  device_name = "/dev/sdm"
  volume_id   = "${aws_ebs_volume.vol8.id}"
  instance_id = "${aws_instance.ec2-instance.id}"
  provisioner "remote-exec" {
    connection {
      user        = "${var.instance_username}"
      host        = "${aws_instance.ec2-instance.private_ip}"
      private_key = "${file("${var.path_to_private_key}")}"
    }
    inline = [
      "chmod +x /tmp/scripts/ebs.sh",
      #"sudo /tmp/scripts/ebs.sh",
      "chmod +x /tmp/scripts/oracle.sh",
      #"sudo /tmp/scripts/oracle.sh",
    ]
  }
}



