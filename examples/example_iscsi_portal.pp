unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}

# Make sure the portal is created
# unity_iscsi_portal { '10.244.213.245':
#   unity_system  => Unity_system['FNM12345678901'],
#   ethernet_port => 'spa_eth3',
#   netmask       => '255.255.255.0',
#   vlan          => 133,
#   gateway       => '10.244.213.1',
#   ensure        => present,
# }

# Tests that the portal is destroyed and recreated
unity_iscsi_portal { '10.244.213.245':
  unity_system  => Unity_system['FNM12345678901'],
  ethernet_port => 'spa_eth3',
  netmask       => '255.255.255.0',
  vlan          => 133,
  gateway       => '10.244.213.1',
  ensure        => present,
}
