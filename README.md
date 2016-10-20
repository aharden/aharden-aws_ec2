# aws_ec2

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with aws_ec2](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with aws_ec2](#beginning-with-aws_ec2)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

`aws_ec2` is a module that implements EC2 resources provided in the `puppetlabs-aws` module with trusted facts as described [here](https://docs.puppet.com/puppet/latest/reference/ssl_attributes_extensions.html). Defined types are provided for Linux and Windows Server nodes, Puppet Enterprise servers, and GitHub Enterprise virtual appliances.  It builds on the examples given in the `puppetlabs-aws` module and in Puppet presentations on AWS deployment with Puppet.

This module can be used to set up an arbiter that manages AWS infrastructure in as code.  An arbiter is a micro EC2 instance running a Puppet agent that is classified with the AWS resources you want it to manage.  The module includes an interactive test suite that implements a Puppet Enterprise monolithic server with Linux and Windows Server agent nodes.

## Setup

### Setup Requirements **OPTIONAL**

An arbiter can be deployed to leverage the module's defined types; they represent configuration instructions for virtual infrastructure.  The current release requires the arbiter to have the AWS IAM policy "AmazonEC2FullAccess" granted.  It's recommended to create an IAM role specifically for the Puppet arbiter, attach the required policies to it, and deploy the arbiter with that role.

It's recommended to use this module's defined types in a "stacks of blocks" pattern that's similar to the "roles and profiles" pattern recommended by Puppet.  Because this code manages virtual infrastructure running operating systems and applications that will be managed by roles and profiles, we thought it would be best to deploy these classes in a separate, but parallel, manner.  Block and stack classes can live in a Puppet control repo alongside role and profile classes.

Blocks are resource declarations of virtual infrastructure required to deploy a certain application. (i.e. ElasticSearch cluster)

Stacks include the blocks required to deploy an solution stack.  (i.e. ElasticSearch, Logstash, & Kibana analytics solution)  They control ordering (if required) and are classified to desired arbiters.  Complex applications can be deployed be combining this with Puppet Enterprise Application Orchestration.

A combination of resource metaparameters and discovered data are written into the certificate signing request of the `aws_ec2::linuxnode` and `aws_ec2::windowsnode` defined types, making them available as trusted facts in PE 2015.2 and later.  They can be used for secure classification (look in `Facts/trusted[extensions]` hash).  These are implemented in line with the [Certificate Signing Attributes reference](https://docs.puppet.com/puppet/latest/reference/ssl_attributes_extensions.html).


### Beginning with aws_ec2

Once the arbiter is deployed, classify it with the module's base class to install the prerequisites:
```puppet
include ::aws_ec2
```

The module's defined types can also be used with interactive manifest runs, as show in the examples.

## Usage

### Creating Blocks
#### Defining an EC2 Linux instance
```puppet
class blocks::aws::us_east::my_linux_application {
  aws_ec2::linuxnode { 'mylinuxapplication.mycompany.com':
    app_id             => 'my_application'
    availability_zone  => 'us-east-1a',
    cost_center        => 12345,
    instance_type      => 't2.micro',
    key_name           => 'my_aws_key_pair',
    owner_email        => 'john.doe@mycompany.com',
    pe_master_hostname => 'puppet.mycompany.com',
    project            => 'my_project',
    role               => 'my_application',
    subnet             => 'my_aws_subnet',
  }
}
```

#### Defining an EC2 Windows instance
```puppet
class blocks::aws::us_east::my_win_application {
  aws_ec2::windowsnode { 'mywinapplication.mycompany.com':
    app_id             => 'my_application',
    availability_zone  => 'us-east-1a',
    cost_center        => 12345,
    instance_type      => 't2.micro',
    key_name           => 'my_aws_key_pair',
    owner_email        => 'john.doe@mycompany.com',
    pe_master_hostname => 'puppet.mycompany.com',
    project            => 'my_project',
    role               => 'my_application',
    subnet             => 'my_aws_subnet',
  }
}
```

#### Destroying an EC2 instance
To destroy any of these resources, set `ensure => absent`.  The defined types' `ensure` defaults to `present`.
```puppet
class blocks::aws::us_east::my_win_application {
  aws_ec2::linuxnode { 'mywinapplication.mycompany.com':
    ensure => 'absent',
  }
}
```

### Creating a stack
```puppet
class stacks::aws::us_east {
  include ::blocks::aws::us_east::my_linux_application
  include ::blocks::aws::us_east::my_win_application
}
```
Keep adding blocks to a stack as required to deploy desired applications with a particular arbiter.  Deploy additional arbiters as required to manage their application and infrastructure responsibilities, and Puppet agent run times.  It's recommended to run the Puppet agent on arbiters on-demand or on a reduced schedule, since there have been idempotency issues with the puppetlabs-aws module.

### Managing AWS infrastructure
You can use the aws_ec2 module as a launching pad for generic Linux/Windows EC2 instances that will be customized using Puppet roles, or you can fork this module and create defined types with embedded applications installed prior to Puppet management.  The defined type ```aws::pe``` uses customized userdata to deploy a monolithic Puppet Enterprise server.


## Reference

### Type
`aws_ec2`: Installs the prerequisites for an arbiter to be able to leverage the puppetlabs-aws resources and manage AWS infrastructure.

### Defines
* `aws_ec2::arbiter`: Sets up an arbiter EC2 instance.
* `aws_ec2::ghe`: Sets up a GitHub Enterprise EC2 instance.
* `aws_ec2::linuxnode`: Sets up a Linux EC2 instance (Ubuntu 16.04/14.04 LTS and Amazon Linux supported).
* `aws_ec2::pe`: Sets up a monolithic Puppet Enterprise 2016.2 server.
* `aws_ec2::windowsnode`: Sets up a Windows Server EC2 instance (versions 2008 R2, 2012, 2012 R2 supported).

### Parameters

#### Type: `aws_ec2`

##### `proxy_url`

**String** URL for the proxy server to be used to communicate with the internet.  Default value: 'http://proxydirect.tycoelectronics.com:80'

#### Defines (common)

##### `nodename`

**(Namevar)** **String** The user-friendly FQDN of the EC2 instance.  This is used as its DNS Alias/CNAME and the Name of the instance in EC2.

##### `availability_zone`

**String** The AWS EC2 availability zone to deploy into.  Defaults to the availability zone the arbiter is running in.

##### `cost_center`

**String** 5-digit TE cost center (added as an instance tag).

##### `ensure`

**String** Desired state of EC2 instance.  Default: 'present'.  Other options: 'running', 'absent', and 'stopped'.

##### `instance_type`

**String** The EC2 instance type to use.  Defaults to 't2.micro' in all types except for `aws_ec2::ghe`, which defaults to 'r3.large', and `aws_ec2::pe`, which defaults to 'm3.large'.

##### `key_name`

**String** The EC2 key pair to assign to the instance.  Defaults to 'puppet'.  Unless you have the puppet keypair's private key, you should use your key pair's name.

##### `owner_email`

**String** Email address of server/application admin.

##### `project`

**String** Project's SSR number (added as an instance tag).

##### `pe_master_hostname`

**String** FQDN of the Puppet Enterprise deployment to join.  Not available/applicable on `aws_ec2::ghe` or `aws_ec2::pe`.

##### `region`

**String** The AWS EC2 region to deploy into.  Defaults to the region the arbiter is running in.

##### `role`

**String** Name of the `role` fact that will be created on this instance.  Useful for matching the deployed node to its desired node group.  Also is added as an instance tag.  Not available/applicable on `aws_ec2::ghe` or `aws_ec2::pe`.

##### `security_groups`

**Array** The Group Name(s) of the EC2 Security Group(s) to assign the instance to.  Defaults to the default Sandbox security group in each supported EC2 region.

##### `subnet`

**String** The EC2 subnet to assign to the instance.  Defaults to the Sandbox subnet in the selected `availability_zone`.

#### Define: `aws_ec2::arbiter`

##### `iam_instance_profile_arn`

**String** The Instance Profile ARN for the IAM role to assign to the instance, in the form 'arn:aws:iam::ID:instance-profile/RoleName'.

##### `image_id`

**String** The AMI to deploy.  Defaults to Ubuntu Linux 14.04 LTS.

#### Define: `aws_ec2::ghe`

##### `disk_size`

**Integer** Size of the instance's data disk in GB.  Default value: 100.

#### Define: `aws_ec2::linuxnode`

##### `app_id`

**String** Application name or ID (added as an instance tag).

##### `department`

**String** The number of the department responsible for the system.

##### `image_id`

**String** The ID of the AMI to deploy.  Defaults to Ubuntu Linux 14.04 LTS.

#### Define: `aws_ec2::pe`

##### `image_id`

**String** The ID of the AMI to deploy.  Defaults to Ubuntu Linux 14.04 LTS.

##### `opt_size`

**Integer** The size of the /opt volume in GB.  Default value: 100.

##### `pe_password`

**String** PE console admin password.  Default value: 'password'.

##### `pe_version`

**String** Desired PE version.  Default value: '2016.2.0'.

##### `var_size`

**Integer** The size of the /var volume in GB.  Default value: 42.

#### Deine: `aws_ec2::windowsnode`

##### `app_id`

**String** Application name or ID (added as an instance tag).

##### `department`

**Integer** The number of the department responsible for the system.

##### `image_id`

**String** The ID of the AMI to deploy.  Defaults to Windows Server 2012 R2.

## Limitations

This module has been tested on Puppet Enterprise 2015.2, 2015.3, and 2016.1.

Ubuntu Linux 14.04 LTS and 16.04 LTS have been tested as arbiters.  Any Linux node running on AWS EC2 with a Puppet 4.x agent should be able to meet the prerequisites for the puppetlabs-aws module.

## Acknowledgement

Much of this was inspired by and borrowed from Chris Barker of Puppet (@mrzarquon on GitHub.com).
