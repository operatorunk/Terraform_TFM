output db_security_group_id {
  value = aws_security_group.db.id
}

output web_security_group_id {
  value = aws_security_group.web.id
}

