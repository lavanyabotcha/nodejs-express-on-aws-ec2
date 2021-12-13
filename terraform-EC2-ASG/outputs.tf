output "elb_dns_name" {
  value       = aws_elb.test-lb-01.dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.test-asg-01.name
  description = "The name of the Auto Scaling Group"
}
