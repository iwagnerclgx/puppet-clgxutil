Facter.add(:is_ec2) do
  setcode do
    if Facter.value(:ec2_metadata)
      true
    else
     false
    end
  end
end
