provider "aws" {}

resource "aws_instance" "database" {
    ami = var.ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.TerraformSG.id]
    key_name = aws_key_pair.ssh_key.key_name
    root_block_device {
      volume_type = "gp2"
      volume_size = "8"
      delete_on_termination = true
  }
  user_data = file("data.sh")
    tags = {
        Name = "Database"
    }
}

resource "aws_instance" "loadbalancer" {
    ami = var.ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.TerraformSG.id]
    key_name = aws_key_pair.ssh_key.key_name
    root_block_device {
      volume_type = "gp2"
      volume_size = "8"
      delete_on_termination = true
  }
  user_data = file("data.sh")
    tags = {
        Name = "LoadBalancer"
    }
}

resource "aws_launch_configuration" "webserver" {
  name   = "WebserverConfig"
  image_id      = var.ami
  instance_type = "t2.micro"
  security_groups = [aws_security_group.TerraformSG.id]
  key_name = aws_key_pair.ssh_key.key_name
  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
  }
  user_data = file("data.sh")
}

resource "aws_autoscaling_group" "TerraformScaling" {
  name = "WebScale"
  availability_zones = ["eu-central-1b"]
  desired_capacity  = 1
  max_size          = 3
  min_size          = 1
  termination_policies = ["NewestInstance"]
  launch_configuration = aws_launch_configuration.webserver.id
  tag {
    key                 = "Name"
    value               = "Webserver"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "TerraformPolicy" {
  name                   = "CPUTarget60"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 0
  autoscaling_group_name = aws_autoscaling_group.TerraformScaling.name
  target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
    }
  target_value = 60.0
  }
}

resource "aws_security_group" "TerraformSG" {
  name = "HTTP/SSH SG"
  description = "This security group created for auto-scaling"
  dynamic "ingress" {
    for_each = ["80", "22","3306"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "sshkey"
  public_key = file("../sshkey.pub")
}


variable "ami" {
  default = "ami-0b418580298265d5c"
}

