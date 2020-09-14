output web-public-ip {
  value = module.instances.web_public_ip
}

output db-instance-address {
  value = module.instances.db_address
}

