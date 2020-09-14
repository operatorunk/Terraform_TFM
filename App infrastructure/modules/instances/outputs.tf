output "web_public_ip" {
  value = "${aws_eip.web.*.public_ip}"
}

output "db_address" {
  value = aws_db_instance.db.address
}