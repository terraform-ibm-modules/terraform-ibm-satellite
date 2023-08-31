locals {
  // arrays with an element per host, specifying flavor
  control_plane_hosts = { for index, item in flatten([
    for host_index, host in var.cp_hosts : [
      for count_index in range(0, host.count) : {
        instance_type = host.instance_type
      }
    ]
  ]) : index => item }

  additional_hosts = { for index, item in flatten([
    for host_index, host in var.addl_hosts : [
      for count_index in range(0, host.count) : {
        instance_type = host.instance_type
      }
    ]
  ]) : index => item }

}
