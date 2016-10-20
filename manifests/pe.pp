# definition for Puppet Enterprise 2016.2 monolithic instance
# parameters:
#   availability_zone: desired AWS avail. zone (default: arbiter's)
#   cost_center: tag for responsible Cost Center
#   ensure: desired state of EC2 instance (default: running)
#   image_id: desired AMI ID (default: Ubuntu 14.04)
#   instance_type: desired EC2 instance type (default: m4.large)
#   key_name: AWS key pair name to use (default: 'puppet')
#   nodename: defaults to resource title
#   owner_email: tag for email address of responsible owner
#   pe_password: PE console admin password (default: password)
#   pe_version: desired PE version (default: arbiter's)
#   project: associated project
#   region: desired AWS region (default: arbiter's)
#   security_groups
#   subnet
define aws_ec2::pe (
  String  $owner_email,
  String  $project,
  String  $availability_zone = $aws_ec2::availability_zone,
  String  $cost_center       = undef,
  String  $ensure            = $aws_ec2::ensure,
  String  $image_id          = $aws_ec2::ubuntu1404,
  String  $instance_type     = $aws_ec2::pe_instance_type,
  String  $key_name          = $aws_ec2::key_name,
  String  $nodename          = $title,
  Integer $opt_size          = $aws_ec2::pe_mono_opt,
  String  $pe_password       = $aws_ec2::pe_password,
  String  $pe_version        = $aws_ec2::pe_version,
  String  $proxy_url         = $aws_ec2::proxy_url,
  String  $region            = $aws_ec2::region,
  Array   $security_groups   = $aws_ec2::security_groups,
  String  $subnet            = $aws_ec2::subnet,
  Integer $var_size          = $aws_ec2::pe_mono_var,
) {
  $app_id            = 'Puppet Enterprise'

  ec2_instance { $nodename:
    ensure            => $ensure,
    availability_zone => $availability_zone,
    image_id          => $image_id,
    instance_type     => $instance_type,
    key_name          => $key_name,
    region            => $region,
    security_groups   => $security_groups,
    subnet            => $subnet,
    tags              => {
      'AppID'      => $app_id,
      'CostCenter' => $cost_center,
      'OwnerEmail' => $owner_email,
    },
    block_devices     => [
      {
        device_name => '/dev/sda1',
        volume_size => 20,
        volume_type => 'gp2',
      },
      {
        device_name => '/dev/sdb',
        volume_size => $opt_size,
        volume_type => 'gp2',
      },
      {
        device_name => '/dev/sdc',
        volume_size => $var_size,
        volume_type => 'gp2',
      }
    ],
    user_data         => template("${module_name}/pe.erb"),
  }
}
