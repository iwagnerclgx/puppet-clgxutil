
$Env:Path += ";C:\Program Files\Puppet Labs\Puppet\bin"

puppet apply -e "class {'static_custom_facts': purge_unmanaged => true, custom_facts => {} }"

cd c:/windows/temp

remove-item *.msi
remove-item *.exe
remove-item *.msu
remove-item *.zip

remove-item -recurse c:/windows/temp/puppet
