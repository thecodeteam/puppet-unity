#!/usr/bin/ruby -w

# Copyright (c) 2017 Dell Inc. or its subsidiaries.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
require 'puppet/util/dellemc/unity_helper'

Puppet::Type.type(:unity_pool).provide(:pool_provider) do
  @doc = 'Manage Unity system related information.'

  mk_resource_methods

  def initialize(*args)
    super *args
    # Define an instance variable that hold values to be synchronized.
    @property_flush = {}
  end

  def create
    Puppet.info "Creating pool #{@resource[:name]} with raid #{@resource[:raid_groups]}."
    unity = get_unity_system(resource[:unity_system])

    params = get_raid_group_parameters(@resource[:raid_groups])
    # Note: need the ! if we pass kwargs to the Python method
    unity.create_pool!(@resource[:name], params, @resource[:description],
                       alert_threshold: @resource[:alert_threshold],
                       is_harvest_enabled: @resource[:is_harvest_enabled],
                       is_snap_harvest_enabled: @resource[:is_snap_harvest_enabled],
                       pool_harvest_high_threshold: @resource[:pool_harvest_high_threshold],
                       pool_harvest_low_threshold: @resource[:pool_harvest_low_threshold],
                       snap_harvest_high_threshold: @resource[:snap_harvest_high_threshold],
                       snap_harvest_low_threshold: @resource[:snap_harvest_low_threshold],
                       is_fast_cache_enabled: @resource[:is_fast_cache_enabled],
                       is_fastvp_enabled: @resource[:is_fastvp_enabled],
                       pool_type: @resource[:pool_type])
    @property_hash[:ensure] = :present

  end

  def destroy
    warning "Deleting pool #{@resource[:name]}."
    unity = get_unity_system(@resource[:unity_system])
    begin
      pool = unity.get_pool(nil, @resource[:name])
    rescue => e
      Puppet.info("Pool #{@resource[:name]} is already deleted #{e.message}.")
      pool = nil
    end
    pool.delete
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.info "Checking existence of pool #{@resource[:name]} ."
    unity = get_unity_system(resource[:unity_system])
    begin
      pool = unity.get_pool!(name: @resource[:name])
    rescue => e
      Puppet.info("Pool #{@resource[:name]} is not found: #{e.message}")
      pool = nil
    end

    if pool == nil
      return false
    end
    true
  end

  def flush
    Puppet.info 'Flushing pool info.'
    return if @property_hash[:ensure] == :absent

    diff = {}

    pool = pool_get
    @property_hash = pool_property pool

    @property_hash.each do |key, value|

      if @resource[key].nil?
        next
      end

      # Compare whether contains new disks/disk groups
      if key == :raid_groups
        add_rgs= []
        @resource[key].each do |raid_group|
          # If disk_num increases, add to diff
          dg_name = raid_group['disk_group']
          if value.has_key? dg_name
            if value[dg_name] < raid_group['disk_num']
              Puppet.info "User increases the disk number to #{raid_group['disk_num']} for pool #{pool.id}"
              add_rg = {}
              add_rg['disk_group'] = dg_name
              add_rg['raid_type'] = raid_group['raid_type']
              add_rg['disk_num'] = -(value[dg_name] - raid_group['disk_num'])
              add_rg['stripe_width'] = raid_group['stripe_width']
              Puppet.info "Adding new disks from #{add_rg} to pool #{pool.id}."

              add_rgs << add_rg
            elsif value[dg_name] > raid_group['disk_num']
              Puppet.warning "Cannot shrink the pool, did you decrease disk num for disk_group #{dg_name} occasionally?"
            end
          else
            Puppet.info "Adding new raid group #{raid_group} to pool #{pool.id}."
            add_rgs << raid_group
          end
        end
        unless add_rgs.empty?
          add_rgs = get_raid_group_parameters(add_rgs)
          diff[key] = add_rgs
        end
        next
      end # End of if key == :raid_groups
      unless value == @resource[key]
        diff[key] = @resource[key]
      end
    end
    unless diff.empty?
      Puppet.info "Modifying the pool properties with change #{diff}"
      pool.modify!(diff)
    end
  end


  def pool_get
    unity = get_unity_system(@resource[:unity_system])
    unity.get_pool!(name: @resource[:name])
  end

  def pool_property pool
    if pool.nil?
      pool = pool_get
    end
    curr = {}

    curr[:description] = pool.description
    dgs = {}
    # We only care whether user add add new disk groups
    # or new disks in existing disk group.
    disk_groups = pool.disk_groups
    disk_groups.to_enum.each do |dg_name|
      dgs[dg_name.to_s] = disk_groups[dg_name.to_s].__len__
    end
    curr[:raid_groups] = dgs

    curr[:alert_threshold] = pool.alert_threshold
    curr[:is_harvest_enabled] = pool.is_harvest_enabled
    curr[:is_snap_harvest_enabled] = pool.is_snap_harvest_enabled
    curr[:pool_harvest_high_threshold] = pool.pool_space_harvest_high_threshold
    curr[:pool_harvest_low_threshold] = pool.pool_space_harvest_low_threshold
    curr[:snap_harvest_high_threshold] = pool.snap_space_harvest_high_threshold
    curr[:snap_harvest_low_threshold] = pool.snap_space_harvest_low_threshold
    curr[:is_fast_cache_enabled] = pool.is_fast_cache_enabled
    if pool.pool_fast_vp.nil?
      curr[:is_fastvp_enabled] = false
    else
      curr[:is_fastvp_enabled] = pool.pool_fast_vp.is_schedule_enabled

    end
    Puppet.info "Pool properties: #{curr}."
    curr
  end
end

