locals {
  hosts = merge({
    for i, host in var.cp_hosts :
    i => {
      instance_type     = host.instance_type
      count             = host.count
      for_control_plane = true
    }
    }, {
    for i, host in var.addl_hosts :
    sum([i, length(var.cp_hosts)]) => {
      instance_type     = host.instance_type
      count             = host.count
      for_control_plane = false
    }
  })
}
