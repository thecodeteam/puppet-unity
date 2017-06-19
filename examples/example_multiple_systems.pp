# Define the first system
unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
  ensure   => present,
}

# define the second system
unity_system { 'APM00150602415':
  ip       => '192.168.1.58',
  user     => 'admin',
  password => 'Password123!',
  ensure   => present,
}

# Create a lun in the first system
unity_pool { 'puppet_pool':
  unity_system => Unity_system['FNM00150600267'],
  ensure       => present,
}
unity_lun { 'puppet_lun_1':
  unity_system => Unity_system['FNM00150600267'],
  pool         => Unity_pool['puppet_pool'],
  size         => 30,
  thin         => true,
  compression  => false,
  sp           => 0,
  description  => "Created by puppet_unity.",
  ensure       => present,
}

# create another lun in the second system
unity_pool { 'Manila_pool':
  unity_system => Unity_system['APM00150602415'],
  ensure       => present,
}
unity_lun { 'puppet_lun_3':
  unity_system => Unity_system['APM00150602415'],
  pool         => Unity_pool['Manila_pool'],
  size         => 30,
  thin         => true,
  compression  => false,
  sp           => 0,
  description  => "Created by puppet_unity.",
  ensure       => present,
}

