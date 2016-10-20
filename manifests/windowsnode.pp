# definition for Windows nodes
# required parameters:
#   pe_master_hostname: the hostname of the PE master to join
#     (will be consumed in user_data)
#   role: the puppet role to be assigned to this node
# optional parameters:
#   app_environment: application environment [prod, qa, dev, test, nonprod, etc]
#   app_id: application name
#   app_tier: application tier
#   availability_zone: desired AWS avail. zone (default: arbiter's)
#   cluster_name: application cluster name (optional)
#   cost_center: ID of responsible Cost Center
#   department: Department that owns service
#   employee_id: Employee ID of service owner
#   ensure: desired state of EC2 instance (default: running)
#   image_id: desired AMI ID (default: Windows Server 2012 R2)
#   instance_type: desired EC2 instance type
#   key_name: AWS key pair name to use (default: 'puppet')
#   nodename: defaults to resource title
#   owner_email: email address of responsible owner
#   product: Product name
#   project: associated project
#   region: desired AWS region (default: arbiter's)
#   security_groups: desired AWS security groups
#   service: service name
#   software_version: application software version
#   subnet: desired AWS subnet
define aws_ec2::windowsnode (
  String  $pe_master_hostname,
  String  $role,
  String  $app_environment   = $aws_ec2::app_environment,
  String  $app_id            = undef,
  String  $app_tier          = undef,
  String  $availability_zone = $aws_ec2::availability_zone,
  String  $cluster_name      = undef,
  String  $cost_center       = undef,
  String  $department        = undef,
  String  $employee_id       = undef,
  String  $ensure            = $aws_ec2::ensure,
  String  $image_id          = $aws_ec2::windows2012r2,
  String  $instance_type     = $aws_ec2::instance_type,
  String  $key_name          = $aws_ec2::key_name,
  String  $nodename          = $title,
  String  $owner_email       = undef,
  String  $product           = undef,
  String  $project           = undef,
  String  $region            = $aws_ec2::region,
  Array   $security_groups   = $aws_ec2::security_groups,
  String  $service           = undef,
  String  $software_version  = undef,
  String  $subnet            = $aws_ec2::subnet,
) {
  # set trusted facts
  # https://github.tycoelectronics.net/Puppet/documentation/blob/master/TrustedFacts.md
  $pp_application      = $app_id
  $pp_apptier          = $app_tier
  $pp_cloudplatform    = $aws_ec2::cloudplatform
  $pp_cluster          = $cluster_name
  $pp_cost_center      = $cost_center
  $pp_created_by       = $owner_email
  $pp_department       = $department
  $pp_employee         = $employee_id
  $pp_environment      = $environment
  $pp_hostname         = $nodename
  $pp_image_name       = $image_id
  $pp_network          = $subnet
  $pp_product          = $product
  $pp_project          = $project
  $pp_provisioner      = $aws_ec2::provisioner
  $pp_role             = $role
  $pp_securitypolicy   = $security_groups
  $pp_service          = $service
  $pp_software_version = $software_version

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
      'Application' => $app_id,
      'CostCenter'  => $cost_center,
      'OwnerEmail'  => $owner_email,
      'SSRNumber'   => $project,
    },
    user_data         => template("${module_name}/windows.erb"),
  }
}
