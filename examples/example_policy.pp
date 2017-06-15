unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}

unity_io_limit_policy { 'puppet_policy':
  unity_system => Unity_system['FNM00150600267'],
  policy_type => 1,
  description => 'Created by puppet 12',
  max_iops => 1000,
  max_kbps => 20480,
}