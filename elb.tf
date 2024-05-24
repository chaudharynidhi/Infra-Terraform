resource "aws_security_group" "elb_sg" {
  name        = "elb-sg"
  description = "Security group for the ELB"
  vpc_id      = aws_vpc.wordpress-vpc.id
}

resource "aws_security_group_rule" "ingress_elb_http_traffic" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.elb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_elb_https_traffic" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elb_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}


resource "aws_elb" "wordpress-elb" {
  name     = "wordpress-elb"
  internal = false
  //  availability_zones = ["us-west-2a", "us-west-2b"]
  security_groups = [aws_security_group.elb_sg.id]
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  # listener {
  #   instance_port      = 8080
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = aws_acm_certificate.wordpress-certificate.arn
  # }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
  tags = merge(var.tags, {
    Name        = "wordpress-elb"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
}