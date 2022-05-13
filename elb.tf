resource "aws_elb" "web" {
  name = "web"
  security_groups = [
    aws_security_group.elb.id
  ]
  subnets                   = [aws_subnet.pub_sub_1a.id, aws_subnet.pub_sub_1b.id]
  cross_zone_load_balancing = true
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Project = "aws-poc"
  }
}
