output "edge_gateway_name" {
  value = data.vcd_edgegateway.edge.name
}

output "edge_gateway_id" {
  value = data.vcd_edgegateway.edge.id
}

output "external_network_name_1" {
  value = element([for net in data.vcd_edgegateway.edge.external_network : net.name if !tolist(net.subnet)[0].use_for_default_route], 0)
}

output "external_network_name_2" {
  value = element([for net in data.vcd_edgegateway.edge.external_network : net.name if tolist(net.subnet)[0].use_for_default_route], 0)
}

output "default_external_network_ip" {
  value = data.vcd_edgegateway.edge.default_external_network_ip
}

output "external_network_ips" {
  value = tolist(data.vcd_edgegateway.edge.external_network_ips)
}

output "external_network_ips_1" {
  value = tolist(data.vcd_edgegateway.edge.external_network_ips)[0]
}

output "external_network_ips_2" {
  value = tolist(data.vcd_edgegateway.edge.external_network_ips)[1]
}

# added things
output "network_id" {
  value = data.vcd_network_routed_v2.network.id
}

output "network_gateway" {
  value = data.vcd_network_routed_v2.network.gateway
}