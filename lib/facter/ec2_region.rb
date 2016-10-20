Facter.add(:ec2_region) do
  confine do
    Facter.value(:ec2_metadata)
  end
  setcode do
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    region
  end
end