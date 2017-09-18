unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}

# Create a Unity io limit policy (absolute limit)
unity_io_limit_policy { 'puppet_policy':
  unity_system => Unity_system['FNM12345678901'],
  policy_type => 1,
  description => 'Created by puppet 12',
  max_iops => 1000,
  max_kbps => 20480,
  burst_rate => 50,
  burst_time => 10,
  burst_frequency => 2,
}