# test PE deployment - part 1 - deploy PE server
$availability_zone = 'us-east-1a'
$cost_center       = '1234'
$key_name          = 'puppet'
$nodename          = 'puppettest99.mycompany.com'
$owner_email       = 'johndoe@mycompany.com'
$project           = 'Testing Puppet Enterprise'
$region            = 'us-east-1'
$subnet            = 'mysubnet'

include aws_ec2
aws_ec2::pe { $nodename:
  ensure            => present,
  availability_zone => $availability_zone,
  cost_center       => $cost_center,
  key_name          => $key_name,
  owner_email       => $owner_email,
  project           => $project,
  region            => $region,
  subnet            => $subnet,
}
