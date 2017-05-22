unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}

# Make sure the portal is created
# unity_iscsi_portal { '10.244.213.245':
#   unity_system  => Unity_system['FNM00150600267'],
#   ethernet_port => 'spa_eth3',
#   netmask       => '255.255.255.0',
#   vlan          => 133,
#   gateway       => '10.244.213.1',
#   ensure        => present,
# }

# Tests that the portal is destroyed and recreated
unity_iscsi_portal { '10.244.213.245':
  unity_system  => Unity_system['FNM00150600267'],
  ethernet_port => 'spa_eth2',
  netmask       => '255.255.255.0',
  vlan          => 133,
  gateway       => '10.244.213.1',
  ensure        => present,
}