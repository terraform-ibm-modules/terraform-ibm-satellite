data "vcd_nsxt_edgegateway" "edge" {
  name = var.vdc_edge_gateway_name
}

data "vcd_network_routed_v2" "network" {
  name = var.network_name
}
