#!/usr/bin/env ruby
require 'rubypython'


Puppet.info('Initializing RubyPython for loading python[storops].')
RubyPython.start

$storops = RubyPython.import('storops')
$storops.enable_log

$unity_info = {}

def get_unity_system(unity_resource)
  local_unity = @resource.catalog.resource(unity_resource.to_s)
  if $unity_info.include? local_unity[:ip]
    Puppet.info "#{local_unity[:ip]} is already connected, using the cached connection."
    return $unity_info[local_unity[:ip]]
  end
  unity = $storops.UnitySystem.new(local_unity[:ip], local_unity[:user], local_unity[:password])
  $unity_info[local_unity[:ip]] = unity

  unity
end

def get_raid_group_parameters(raid_groups)
  pool = RubyPython.import('storops.unity.resource.pool')
  parameters = []
  raid_groups.each do |raid_group|
    # disk_group = disk.UnityDiskGroup.new(raid_group[:disk_group])
    # Must use 'string' to access the hash instead of :symbol
    # or NoIndexException will be raise
    disk_group = raid_group['disk_group']
    param = pool.RaidGroupParameter.new(disk_group,
                                        raid_group['disk_num'],
                                        raid_group['raid_type'],
                                        raid_group["stripe_width"])
    parameters.push(param)
  end
  parameters
end
