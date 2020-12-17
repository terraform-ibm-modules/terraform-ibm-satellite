# Module AWS EC2

This module is used to create a AWS EC2 instance.

## Example Usage
```
provider "aws" {
}

.....

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count              = var.instance_count
  name                        = var.name
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.web.id
  user_data                   = file(var.input_file_name)

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  tags = {
    "env" = "aws"
  }

}


```

## Inputs

| Name               | Description                                                      | Type         | Default | Required |
|--------------------|------------------------------------------------------------------|:-------------|:------- |:---------|
| instance\_count    | Number of instances to launch.                                   | string       | n/a     | yes      |
| name               | Name to be used on all resources as prefix.                      | string       | n/a     | yes      |
| ami                | ID of AMI to use for the instance.                               | string       | n/a     | yes      |
| instance\_type     | The type of instance to start.                                   | string       | n/a     | yes      |
| key\_name          | The ssh key name to use for the instance.                        | string       | n/a     | yes      |
| input\_file\_name  | Input satellite attach host script.                              | string       | n/a     | yes      |