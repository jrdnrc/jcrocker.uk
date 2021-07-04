resource "aws_lb" "jcrockeruk" {
  name = "jcrocker-ecs-lb"
  internal = false
  load_balancer_type = "application"

  security_groups    = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress-all.id,
  ]
  
  subnets            = [aws_subnet.public.id, aws_subnet.private.id]

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_lb_target_group" "jcrockeruk" {
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.app-vpc.id

  target_type = "ip"

  health_check {
    enabled = true
    path    = "/health.txt"
  }

  depends_on = [aws_lb.jcrockeruk]
}

resource "aws_lb_listener" "jcrockeruk" {
  load_balancer_arn = aws_lb.jcrockeruk.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jcrockeruk.arn
  }
}

output "alb_url" {
  value = "http://${aws_lb.jcrockeruk.dns_name}"
}