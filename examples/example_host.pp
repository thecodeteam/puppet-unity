unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
}

#
# unity_host { 'my_host':
#   unity_system => Unity_system['FNM12345678901'],
#   ip => '192.168.1.130',
#   os_type => 'Ubuntu',
#   host_type => 1,
#   iqn => 'iqn.1993-08.org.debian:01:unity-puppet-host',
#   wwns => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D1'],
# }

unity_host { 'my_host':
  unity_system => Unity_system['FNM12345678901'],
  description  => 'Created by puppet',
  ip           => '192.168.1.139',
  os           => 'Ubuntu16',
  host_type    => 1,
  iqn          => 'iqn.1993-08.org.debian:01:unity-puppet-host',
  wwns         => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D3',
    '20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D4'],
  ensure       => present,
}