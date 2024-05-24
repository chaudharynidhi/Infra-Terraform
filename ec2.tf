# resource "aws_vpc_endpoint" "wordpress-ep" {
#   vpc_id       = aws_vpc.main.id
#   service_name = "com.amazonaws.us-west-2.s3"
# }

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Default sg for the EC2 instances"
  vpc_id      = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_health_check" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.elb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "ec2_to_rds" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.sg_db.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_launch_template" "wordpress-template" {
  name                   = "wordpress-template"
  description            = "Launch Template for ASG for wordpress instances"
  image_id               = "ami-0de0c017a5866b353"
  key_name               = "ec2-ssh-key"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64("wordpress.sh")

  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "wordpress-asg" {
  name             = "wordpress-asg"
  max_size         = 10
  min_size         = 2
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.wordpress-template.id
    version = "$Latest"
  }
  // availability_zones = [aws_subnet.public_a.availability_zone, aws_subnet.public_b.availability_zone]
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  load_balancers            = [aws_elb.wordpress-elb.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true

  timeouts {
    delete = "15m"
  }
  termination_policies = ["OldestInstance"]
  tag {
    key                 = "Name"
    value               = "wordpress-instance"
    propagate_at_launch = true
  }
}