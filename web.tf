resource "aws_launch_configuration" "web" {
  name     = "web-launch-configuration"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "aws_ec2_key"
  security_groups = [aws_security_group.web.id]
  user_data = templatefile("web-data.sh", { rds_endpoint = "${aws_db_instance.mysql.address}" })
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_db_instance.mysql,
    aws_nat_gateway.ngw_1a
  ]
}

resource "aws_autoscaling_group" "web" {
  name             = "web-autoscaling-group"
  min_size         = 1
  desired_capacity = 1
  max_size         = 2
  //health_check_type = "ELB"
  health_check_type = "EC2"
  load_balancers = [aws_elb.web.id]
  launch_configuration = aws_launch_configuration.web.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  vpc_zone_identifier = [
  aws_subnet.web_prv_sub_1a.id,
  aws_subnet.web_prv_sub_1b.id]
  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      "key"                 = "Name"
      "value"               = "web"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Project"
      "value"               = "aws-poc"
      "propagate_at_launch" = true
    },
  ]
}

resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}
