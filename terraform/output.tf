output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_ip" { value = aws_instance.app.public_ip }
output "app_url"   { value = "http://${aws_instance.app.public_ip}" }