
This is another project aiming at utilizing the versatility of terraform to create infrastructure.

This is by no means my proper readme and will make a proper one soon. 

But for now if you run `terraform apply` you will create VPCs, public and private subnets, routes, IGW and basically everything else needed to result in public and private subnets (you can define the number of each you want), with EC2 instances in them. 

The setup with also be that of a bastion host with the instance in the public subnet being the only way to access the instance in the private subnet.

Many updates coming soon.

......somebody said something about modules?