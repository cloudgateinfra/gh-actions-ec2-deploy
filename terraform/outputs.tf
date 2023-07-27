output "elastic_ip_public_dns" {
  value = aws_eip.eip.public_dns
}
