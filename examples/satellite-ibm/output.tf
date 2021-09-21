

output "location_id" {
  value = module.satellite-location.location_id
}

output "host_script" {
  value = module.satellite-location.host_script
}
output "host_ids" {
  value = ibm_is_instance.satellite_instance.*.id
}
output "floating_ip_ids" {
  value = ibm_is_floating_ip.satellite_ip.*.id
}
output "floating_ip_addresses" {
  value = ibm_is_floating_ip.satellite_ip.*.address
}
output "vpc" {
  value = ibm_is_vpc.satellite_vpc.id
}
output "default_security_group" {
  value = ibm_is_vpc.satellite_vpc.default_security_group
}
output "subnets" {
  value = ibm_is_subnet.satellite_subnet.*.id
}