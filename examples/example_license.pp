unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}


unity_license { 'C:/Users/wangp11/RubymineProjects/puppet-unity/examples/license-any-host-Merlin-ESSENTIAL.lic':
  unity_system => Unity_system['FNM12345678901'],
  ensure       => present,
}
