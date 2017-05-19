unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}


unity_iscsi_portal { '10.244.213.245':
  unity_system => Unity_system['FNM00150600267'],
  ethernet_port => 'spa_eth3',
  netmask       => '255.255.255.0',
  vlan          => '133',
  gateway       => '10.244.213.1',
  ensure        => present,
}