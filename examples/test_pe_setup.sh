#!/bin/bash
# setup prerequisites for aws_ec2 test_pe manifests on Ubuntu Linux on AWS
# instance must have IAM role with EC2 deployment rights
# must be run as root
# proxy information can be uncommented and added as required
#PROXY_HOST='proxy.mycompany.com'
#PROXY_PORT='8080'
#HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
REGION='us-east-1'
MODULE='aharden-aws_ec2'
# Ubuntu Linux 14.04 = trusty
UBUNTU_RELEASE='trusty'
# Ubuntu Linux 16.04 = xenial
#UBUNTU_RELEASE='xenial'

# inject HTTP proxy if required
#cat > /etc/apt/apt.conf << APTCONF
#Acquire::http::Proxy "$HTTP_PROXY";
#APTCONF

/usr/bin/curl -O https://apt.puppetlabs.com/puppetlabs-release-pc1-$UBUNTU_RELEASE.deb
#/usr/bin/curl -x $HTTP_PROXY -O https://apt.puppetlabs.com/puppetlabs-release-pc1-$UBUNTU_RELEASE.deb
dpkg -i puppetlabs-release-pc1-$UBUNTU_RELEASE.deb
apt update
apt install git puppet-agent -y
#/opt/puppetlabs/bin/puppet config set --section main http_proxy_host $PROXY_HOST
#/opt/puppetlabs/bin/puppet config set --section main http_proxy_port $PROXY_PORT
/opt/puppetlabs/puppet/bin/gem install aws-sdk-core retries
#/opt/puppetlabs/puppet/bin/gem install --http-proxy $HTTP_PROXY aws-sdk-core retries
/opt/puppetlabs/bin/puppet module install puppetlabs-aws
/opt/puppetlabs/bin/puppet module install $MODULE

cat > /etc/puppetlabs/puppet/puppetlabs_aws_configuration.ini << AWSCONF
[default]
  http_proxy = $HTTP_PROXY
  region = $REGION
AWSCONF

# Manually run the following to build the test environment:
# $ /opt/puppetlabs/bin/puppet apply /opt/puppetlabs/puppet/modules/aws_ec2/examples/test_pe_server.pp
# Add pe_repo::platform classes required to support agent installs on new PE server.
# Then run this to create Linux and Windows test nodes:
# $ /opt/puppetlabs/bin/puppet apply /opt/puppetlabs/puppet/modules/aws_ec2/examples/test_pe_agents.pp
