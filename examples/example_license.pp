unity_system { 'FNM00150600267':
  ip       => '10.245.101.39',
  user     => 'admin',
  password => 'Password123!',
}


unity_license { 'C:/Users/wangp11/RubymineProjects/puppet-unity/examples/license-any-host-Merlin-ESSENTIAL.lic':
  unity_system => Unity_system['FNM00150600267'],
  ensure       => present,
}
