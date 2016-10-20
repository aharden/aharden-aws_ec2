#!/bin/bash
# meant to be run on a PE monolithic master or console server
MD="http://169.254.169.254/latest/meta-data/"
PE_HOSTNAME=$(curl -fs $MD/hostname)
NODE_GROUP_ID=<node_group_guid>
# get JSON for a node group to edit:
curl --tlsv1 https://$PE_HOSTNAME:4433/classifier-api/v1/groups/$NODE_GROUP_ID --cert /etc/puppetlabs/puppet/ssl/certs/$PE_HOSTNAME.pem --key /etc/puppetlabs/puppet/ssl/private_keys/$PE_HOSTNAME.pem --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem -H "Content-Type: application/json" > nogegroup.json
# edit nodegroup.json, adding/editing a roles line:
# "rule":["=",["trusted","extensions","pp_role"],"<desired_role_name>"],
#
# PUT the new node group configuration on the server:
curl --tlsv1 -X POST -d @nodegroup.json https://$PE_HOSTNAME:4433/classifier-api/v1/groups/$NODE_GROUP_ID --cert /etc/puppetlabs/puppet/ssl/certs/$PE_HOSTNAME.pem --key /etc/puppetlabs/puppet/ssl/private_keys/$PE_HOSTNAME.pem --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem -H "Content-Type: application/json"
