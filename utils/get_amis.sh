#!/bin/bash

#simple script to output common ami_ids we use for when we need to update hieradata
#derived from: https://github.com/mrzarquon/puppet-tse_awsnodes/blob/master/ext/get_amis.sh

REGIONS=('us-east-1' 'us-west-1')

for region in "${REGIONS[@]}"; do
  # ubuntu 14.04 & 16.04
  aws ec2 describe-images --owners 099720109477 --region $region --filters Name=virtualization-type,Values=hvm Name=state,Values=available Name=name,Values=*images/*ssd*trust*2016*,*images/*ssd*xenial*2016* Name=root-device-type,Values='ebs' --query 'Images[*].{Name:Name,AMI:ImageId}' --output text | sort -k2 > $region.txt
  sleep 5
  # redhat 6 & 7
  aws ec2 describe-images --owners 309956199498 --region $region --filters Name=name,Values=*6*,*7* Name=virtualization-type,Values=hvm Name=state,Values=available --query 'Images[*].{Name:Name,AMI:ImageId}' --output text | sort -k2 >> $region.txt
  sleep 5
  # windows 2008 r2, 2012, 2012 r2
  aws ec2 describe-images --owners 801119661308 --region $region --filters Name=name,Values=*2012*English*Base*,*2008*SP2*English*64Bit*Base* Name=virtualization-type,Values=hvm Name=state,Values=available --query 'Images[*].{Name:Name,AMI:ImageId}' --output text | sort -k2 >> $region.txt
  sleep 5
  # amazon linux 2016
  aws ec2 describe-images --owners 137112412989 --region $region --filters Name=name,Values=*2016* Name=virtualization-type,Values=hvm Name=state,Values=available --query 'Images[*].{Name:Name,AMI:ImageId}' --output text | sort -k2 >> $region.txt
done <<< $REGIONS
