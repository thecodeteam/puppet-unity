# Define the first system
unity_system { 'FNM12345678901':
  ip       => '192.168.1.50',
  user     => 'admin',
  password => 'password',
  ensure   => present,
}

# define the second system
unity_system { 'APM00150602415':
  ip       => '192.168.1.58',
  user     => 'admin',
  password => 'password',
  ensure   => present,
}

# Create a lun in the first system
unity_pool { 'puppet_pool':
  unity_system => Unity_system['FNM12345678901'],
  ensure       => present,
}
unity_lun { 'puppet_lun_1':
  unity_system => Unity_system['FNM12345678901'],
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

