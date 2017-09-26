#!/bin/bash

export PATH=$PATH:/opt/puppetlabs/bin

puppet apply -e "class {'static_custom_facts': purge_unmanaged => true, custom_facts => {} }"

rm -f /tmp/*.{zip,tar,tar.gz,tgz}
rm -Rf /tmp/puppet
