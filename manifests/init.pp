# Class: aws_ec2
# Defines available resources for AWS EC2
# Installs prereqs for puppetlabs/aws module
class aws_ec2 (
  # default values are in aws_ec2/data
  String  $amazonlinux,
  String  $app_environment,
  String  $centrify_zone,
  String  $cloudplatform,
  String  $ensure,
  String  $instance_type,
  String  $key_name,
  Integer $pe_mono_opt,
  Integer $pe_mono_var,
  String  $pe_version,
  String  $provisioner,
  String  $proxy_url,
  Array   $security_groups,
  String  $subnet,
  String  $ubuntu1404,
  String  $ubuntu1604,
  String  $vpc_id,
  String  $windows2008r2,
  String  $windows2012,
  String  $windows2012r2,
) {
  # calculate the default availability_zone and region if not specified
  $availability_zone = $::facts['ec2_metadata']['placement']['availability-zone']
  $region            = $::facts['ec2_region']

  # install required ruby gems for Puppetlabs/aws
  package { ['aws-sdk-core','retries']:
    ensure   => present,
    provider => 'puppet_gem',
  }

  # module configuration file (as of puppetlabs/aws 1.3.0)
  file { "${settings::confdir}/puppetlabs_aws_configuration.ini":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/puppetlabs_aws_configuration.ini.erb"),
  }
}
