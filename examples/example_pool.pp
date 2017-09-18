unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}



unity_pool { 'puppet_pool':
  unity_system            => Unity_system['FNM12345678901'],
  description             => 'created by puppet module',
  raid_groups             => [{
    disk_group   => 'dg_15',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }],
  alert_threshold         => 80,
  is_snap_harvest_enabled => false,
  snap_harvest_high_threshold => 24.0,
  is_harvest_enabled      => true,
  pool_type               => 2,
  ensure                  => absent,
}

# uncomment the following manifest for a pool expansion

# unity_pool { 'puppet_pool':
#   unity_system            => Unity_system['FNM12345678901'],
#   description             => 'created by puppet module',
#   raid_groups             => [{
#     disk_group   => 'dg_15',
#     raid_type    => 1,
#     stripe_width => 0,
#     disk_num     => 5,
#   }, {
#     disk_group   => 'dg_8',
#     raid_type    => 7,
#     stripe_width => 0,
#     disk_num     => 4,
#   }],
#   alert_threshold         => 80,
#   is_snap_harvest_enabled => true,
#   snap_harvest_high_threshold => 25.0,
#   is_harvest_enabled      => true,
#   pool_type               => 2,
#   ensure                  => present,
# }



