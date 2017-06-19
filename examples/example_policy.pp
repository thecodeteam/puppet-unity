unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}

# Create a Unity io limit policy (absolute limit)
unity_io_limit_policy { 'puppet_policy':
  unity_system => Unity_system['FNM00150600267'],
  policy_type => 1,
  description => 'Created by puppet 12',
  max_iops => 1000,
  max_kbps => 20480,
  burst_rate => 50,
  burst_time => 10,
  burst_frequency => 2,
}