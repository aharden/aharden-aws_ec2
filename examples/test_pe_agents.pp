# test PE deployment - part 2 - deploy PE agents
# deploy part 1 first, or adjust $pe_master_hostname to an existing PE server
$app_tier           = 'test'
$availability_zone  = 'us-east-1a'
$cluster_name       = 'n/a'
$cost_center        = 'n/a'
$department         = 'n/a'
$employee_id        = '012345'
$key_name           = 'puppet'
$linux_app_id       = 'Test PE Linux'
$linux_nodename     = 'puppettestl99.mycompany.com'
$owner_email        = 'example@te.com'
$pe_master_hostname = 'puppettest99.mycompany.com'
$product            = 'Puppet Enterprise'
$project            = 'Testing Puppet Enterprise'
$region             = 'us-east-1'
$role               = 'roles::default'
$service            = 'Puppet Enterprise (Test)'
$software_version   = '0.1.0'
$subnet             = 'mysubnet'
$win_app_id         = 'Test PE Windows'
$win_nodename       = 'puppettestw99.mycompany.com'

include aws_ec2

aws_ec2::linuxnode { $linux_nodename:
  ensure             => present,
  app_id             => $linux_app_id,
  app_tier           => $app_tier,
  availability_zone  => $availability_zone,
  cluster_name       => $cluster_name,
  cost_center        => $cost_center,
  department         => $department,
  employee_id        => $employee_id,
  key_name           => $key_name,
  owner_email        => $owner_email,
  pe_master_hostname => $pe_master_hostname,
  product            => $product,
  project            => $project,
  region             => $region,
  role               => $role,
  service            => $service,
  software_version   => $software_version,
  subnet             => $subnet,
}

aws_ec2::windowsnode { $win_nodename:
  ensure             => present,
  app_id             => $win_app_id,
  app_tier           => $app_tier,
  availability_zone  => $availability_zone,
  cluster_name       => $cluster_name,
  cost_center        => $cost_center,
  department         => $department,
  employee_id        => $employee_id,
  key_name           => $key_name,
  owner_email        => $owner_email,
  pe_master_hostname => $pe_master_hostname,
  product            => $product,
  project            => $project,
  region             => $region,
  role               => $role,
  service            => $service,
  software_version   => $software_version,
  subnet             => $subnet,
}
