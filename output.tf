output "public-ip" {
  value = aws_instance.corp-webserver.public_ip
}