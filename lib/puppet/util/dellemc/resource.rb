#!/usr/bin/env ruby
require 'rubypython'

Puppet.info('Initializing RubyPython for loading python[storops].')
RubyPython.start

$storops = RubyPython.import('storops')
$storops.enable_log

def get_unity_system(unity_resource)
  unity = $storops.UnitySystem(unity_resource[:ip], unity_resource[:user], unity_resource[:password])
end


def get_raid_group_parameters(raid_groups)
  parameter_type = RubyPython.import('storops.unity.resource.pool.RaidGroupParameter')
  disk_group_type = RubyPython.import('storops.unity.resource.disk.UnityDiskGroup')
  parameters = []
  raid_groups.each do |raid_group|
    disk_group = disk_group_type.new(raid_group[:disk_group])
    param = parameter_type.new(disk_group, raid_group[:disk_num], raid_group[:raid_type], raid_type[:stripe_width])
    parameters.push(param)
  end
  parameters
end

def get_unity_exception
  RubyPython.import("storops.exception").UnityException
end