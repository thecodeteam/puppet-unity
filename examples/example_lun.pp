unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}
notice("License")


unity_lun { 'puppet_lun':
  unity_system => Unity_system['FNM00150600267'],
  size => 10,
  thin => true,
  compression => true,

}
