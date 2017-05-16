#!/usr/bin/env ruby
require 'rubypython'

Puppet.info('Initializing RubyPython for loading python[storops].')
RubyPython.start

$storops = RubyPython.import('storops')
$storops.enable_log

def get_unity_system(unity_resource)
  local_unity = resource.catalog.resource(unity_resource.to_s)
  unity = $storops.UnitySystem.new(local_unity[:ip], local_unity[:user], local_unity[:password])
end


def get_raid_group_parameters(raid_groups)
  pool = RubyPython.import('storops.unity.resource.pool')
  disk = RubyPython.import('storops.unity.resource.disk')
  parameters = []
  raid_groups.each do |raid_group|
    # disk_group = disk.UnityDiskGroup.new(raid_group[:disk_group])
    disk_group = raid_group[:disk_group]
    param = pool.RaidGroupParameter.new(disk_group,
                                        raid_group[:disk_num],
                                        raid_group[:raid_type],
                                        raid_group[:stripe_width])
    parameters.push(param)
  end
  parameters
end
