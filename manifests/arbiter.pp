# Class: aws_ec2::arbiter
# Creates AWS arbiter EC2 instance
class aws_ec2::arbiter (
  String  $cost_center,
  String  $iam_instance_profile_arn,
  String  $owner_email,
  String  $pe_master_hostname,
  String  $project,
  String  $role,
  String  $availability_zone = $aws_ec2::availability_zone,
  String  $centrify_zone     = $aws_ec2::centrify_zone,
  String  $image_id          = $aws_ec2::ubuntu1404,
  String  $instance_type     = $aws_ec2::instance_type,
  String  $key_name          = $aws_ec2::key_name,
  String  $nodename          = $title,
  String  $region            = $aws_ec2::region,
  Array   $security_groups   = $aws_ec2::security_groups,
  String  $subnet            = $aws_ec2::subnet,
) {
  include aws

  ec2_instance { $nodename:
    ensure                   => 'running',
    availability_zone        => $availability_zone,
    block_devices            => [
      {
        device_name => '/dev/sda1',
        volume_size => 8,
      }
    ],
    image_id                 => $image_id,
    iam_instance_profile_arn => $iam_instance_profile_arn,
    instance_type            => $instance_type,
    key_name                 => $key_name,
    region                   => $region,
    security_groups          => $security_groups,
    subnet                   => $subnet,
    tags                     => {
      'AppID'      => 'Puppet Enterprise',
      'CostCenter' => $cost_center,
      'SSRNumber'  => $project,
      'OwnerEmail' => $owner_email,
    },
    user_data                => template("${module_name}/linux.erb"),
  }
}
