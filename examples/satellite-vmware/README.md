# satellite-vmware
Use this Terraform automation to set up a Satellite location on IBM Cloud with hosts in VMware Cloud Director.

This example will:
- Create an [IBM Cloud Satellite](https://cloud.ibm.com/satellite) location
- Create Red Hat Core OS VMs in VMware Cloud Director with 3 different specifications: control plane, worker, and storage
- Attach the VMs to the Satellite location
- Assign the control plane VMs to the Satellite location control plane

The example has been tested within the [IBM Cloud VMware Shared](https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_overview) environment. Other virtual cloud environments may require further customization. It is heavily based on the [Getting Started with IBM Cloud for VMware Shared Solution tutorial](https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-vmware-solutions-shared-getting-started).

## Compatibility

This module is meant for use with Terraform 1.1.9 or later.

## Requirements
- [Terraform](https://www.terraform.io/downloads.html) 1.1.9 or later.
- An IBM Cloud account, with the ability to create Satellite locations
- IC_API_KEY set in the environment as described in the IBM Terraform provider documentation.
- A VMware Virtual Cloud environment, with appropriate permissions and access information.
- Pre-configured networking environment with DHCP enabled.


## Required environment data
The tables below outline the information to gather from your environment before filling out the terraform variable values.

Required to connect to the VMware Cloud Director environment:
| Name                                  | Description                                                       | Example
|---------------------------------------|-------------------------------------------------------------------|--------------|
vcd_user              | The VMware Cloud Director username | admin |
vcd_password          | The VMware Cloud Director password ||
vcd_org               | The VMware organization name | 0ff080abcdef123456789abcd12345678 |
vcd_url               | The VMware Cloud Director URL | `https://daldir01.vmware-solutions.cloud.ibm.com/api` |
vdc_name              | The VMware Cloud Director virtual data center name | vmware-satellite |

<BR/>

Used within the VMware environment when configuring the Virtual Machines and networking:
| Name                                  | Description                                                       | Example
|---------------------------------------|-------------------------------------------------------------------|--------------|
rhcos_template_id     | The ID of the RHCOS 4.12+ template to be used when provisioning the virtual machines      | 158d698b-7498-4038-b48d-70665115f4ea |
dhcp_network_name     | The name of the network pre-configured for the environment         | my-network |
vdc_edge_gateway_name | The name of the edge network configured in the environment. This may not be needed in all applications, but if provided, firewall rules and NAT setup will take place | edge-dal10-12345678 |

Other input information can be found in [variables.tf](variables.tf).

## Networking configuration
This section details what is needed in a [VMware Solutions Shared environment on IBM Cloud](https://cloud.ibm.com/docs/vmwaresolutions?topic=vmwaresolutions-shared_overview) environment. [The Satellite documentation](https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started), can be consulted for more details about what is generally needed.

Before attempting to run the example, the following must be created in the virtual data center:
- A routed VDC network
- An edge gateway, configured with **Distributed Routing** enabled. This network should also be **configured with DHCP**. Add a DHCP pool with IP addresses from the previously created VDC network, and **enable DHCP**.

When running this example, supply the name of the routed VDC network as `dhcp_network_name`. The edge gateway is **optionally** provided as `vdc_edge_gateway_name`. The following will be configured by the example:
- Virtual machines will use the `dhcp_network_name` network, with IPs from the DHCP pool.
- If the `vdc_edge_gateway_name` is provided, firewall rules will be created for full outbound connectivity from the VDC network.
- If the `vdc_edge_gateway_name` is provided, an SNAT rule will be created for mapping to an external IP.


## Compute Details
This example creates Red Hat CoreOS virtual machines for use with IBM Cloud Satellite. A Red Hat CoreOS v4 image must be available in the VMWare environment. Provide its ID in the variable `rhcos_template_id`.


The example will create 3 different sizes of virtual machines:
- Control plane virtual machines (8 CPU, 32GB RAM, 100GB primary disk)
- Worker virtual machines (4 CPU, 16GB RAM, 25GB primary disk, 100GB secondary disk)
- Storage virtual machines (16 CPU, 64GB RAM, 25GB primary disk, 100GB secondary disk, 500GB tertiary disk). The specs for the storage VMs are configurable via terraform variables.

These virtual machines will automatically attach to the Satellite location on boot. The control plane virtual machines will automatically be assigned to the location's control plane.

Further details:
* The `satellite-location` module creates a new location or uses an existing location ID/name. If using an existing location, set `is_location_exist` to `true`.
* The `satellite-location` module downloads the attach host script to the $HOME directory and appends respective permissions to the script.
* The `satellite-location` module will update the attach host script and pass it as ignition data to VMware during VM creation


## Inputs
See [variables.tf](variables.tf) for input information.
