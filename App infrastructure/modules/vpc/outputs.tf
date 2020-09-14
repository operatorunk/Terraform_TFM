output private_sub_ids {
  value = aws_subnet.private.*.id
}

output public_sub_ids {
  value = aws_subnet.public.*.id
}

output private_sub_cidrs {
  value = local.private_subnet_cidrs
}

output public_sub_cidrs {
  value = local.public_subnet_cidrs
}

output subnet_group_name {
  value = aws_db_subnet_group.this.name
}

output vpc_id {
  value = aws_vpc.this.id
}