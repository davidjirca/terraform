# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "alb-sticky-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sticky-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "alb-sticky-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "alb-sticky-web-alb"
  }
}

# Target Group with Session Stickiness
resource "aws_lb_target_group" "web" {
  name     = "alb-sticky-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  # Session Stickiness Configuration
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 24 hours in seconds (range: 1 second to 7 days)
    enabled         = true
  }

  tags = {
    Name = "alb-sticky-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}