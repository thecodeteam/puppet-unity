unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
}

unity_pool { 'puppet_pool':
  unity_system            => Unity_system['FNM00150600267'],
  description             => 'created by puppet module',
  raid_groups             => [{
    disk_group   => 'dg_15',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }],
  alert_threshold         => 80,
  is_snap_harvest_enabled => true,
  is_harvest_enabled      => true,
  ensure                  => present,
}


unity_lun { 'puppet_lun':
  unity_system => Unity_system['FNM00150600267'],
  pool         => Unity_pool['puppet_pool'],
  size         => 20,
  thin         => true,
  compression  => false,
  sp           => 0,
  description  => "Created by puppet_unity.",
  ensure       => present,
}
