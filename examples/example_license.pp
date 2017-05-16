notice("System")
unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}
notice("License")


unity_license { 'C:/Users/wangp11/RubymineProjects/puppet-unity/examples/license-any-host-Merlin-ESSENTIAL.lic':
  unity_system => Unity_system['FNM00150600267'],
  ensure       => present,
}
