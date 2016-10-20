# definition for GitHub Enterprise 2.6.x applicance
# parameters:
#   availability_zone: desired AWS avail. zone (default: arbiter's)
#   cost_center: tag for responsible Cost Center
#   ensure: desired state of EC2 instance (default: running)
#   instance_type: desired EC2 instance type
#   key_name: AWS key pair name to use (default: 'puppet')
#   nodename: defaults to resource title
#   owner_email: tag for email address of responsible owner
#   project: tag for the SSR number of the associated project
#   region: desired AWS region (default: arbiter's)
#   subnet
define aws_ec2::ghe (
  String  $availability_zone = $aws_ec2::availability_zone,
  String  $cost_center       = undef,
  Integer $disk_size         = $aws_ec2::ghe_disk,
  String  $ensure            = $aws_ec2::ensure,
  String  $instance_type     = 'r3.large',
  String  $key_name          = $aws_ec2::key_name,
  String  $nodename          = $title,
  String  $owner_email       = undef,
  String  $project           = undef,
  String  $region            = $aws_ec2::region,
  String  $subnet            = $aws_ec2::subnet,
) {
  $app_id   = 'GitHub Enterprise'
  $image_id = $aws_ec2::github_enterprise

  ec2_securitygroup { 'github-enterprise':
    ensure      => present,
    region      => $region,
    description => 'https://help.github.com/enterprise/2.6/admin/guides/installation/installing-github-enterprise-on-aws/#creating-a-security-group',
    ingress     => [{
      protocol => 'tcp',
      port     => 8443,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 8080,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 122,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'udp',
      port     => 1194,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'udp',
      port     => 161,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 22,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 9418,
      cidr     => '0.0.0.0/0',
    },{
      protocol => 'tcp',
      port     => 25,
      cidr     => '0.0.0.0/0',
    }],
    tags        => {
      'AppID'      => $app_id,
      'CostCenter' => $cost_center,
      'Project'    => $project,
      'OwnerEmail' => $owner_email,
    },
  }

  ec2_instance { $nodename:
    ensure            => $ensure,
    availability_zone => $availability_zone,
    image_id          => $image_id,
    instance_type     => $instance_type,
    key_name          => $key_name,
    region            => $region,
    security_groups   => 'github-enterprise',
    subnet            => $subnet,
    tags              => {
      'AppID'      => $app_id,
      'CostCenter' => $cost_center,
      'Project'    => $project,
      'OwnerEmail' => $owner_email,
    },
    block_devices     => [
      {
        device_name => '/dev/sdb',
        volume_size => $disk_size,
        volume_type => 'gp2',
      }
    ],
  }
}
