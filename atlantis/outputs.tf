output "atlantis_url" {
  value = "${aws_instance.atlantis.public_dns}:4141"
}
