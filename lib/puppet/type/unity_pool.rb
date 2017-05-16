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

Puppet::Type.newtype(:unity_pool) do
  @doc = 'Configure DellEMC Unity storage pool.'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'Unique identifier for the Unity system, typically a serial number.'

  end


  newparam(:description) do
    desc 'Storage pool description.'
    defaultto do
      ''
    end
  end

  newparam(:raid_groups) do
    desc 'Raid groups to be included in the storage pool.'

    validate do |value|
      value.each do |raid_group|
        Puppet.info(raid_group)
        if raid_group['disk_group'] == nil
          raise(Puppet::Error, 'disk_group could not be empty, please specify a disk group id.')
        end
        if raid_group['raid_type'] == nil
          Puppet.info('raid_type is not specified, using Automatic')
          raid_group['raid_type'] = 'Automatic'
        end
        if raid_group['disk_num'] == nil
          raise(Puppet::Error, 'disk_num cannot not be empty, please specify an integer.')
        end
        if raid_group['stripe_width'] == nil
          Puppet.info('stripe_width is not specified, using BestFit.')
          raid_group['stripe_width'] = 0
        end
      end
    end
  end

  newparam(:alert_threshold) do
    desc 'Threshold at which the system will generate alerts about the free space in the pool, specified as a percentage'

  end
  newparam(:is_harvest_enabled) do
    desc 'Enable/disable pool harvesting.'

  end
  newparam(:is_snap_harvest_enabled) do
    desc 'Enable/disable pool snapshot harvesting.'

  end
  newparam(:pool_harvest_high_threshold) do
    desc 'Pool used space high threshold at which the system will automatically starts to delete snapshots in the pool'

  end
  newparam(:pool_harvest_low_threshold) do
    desc 'Pool used space low threshold under which the system will automatically stop deletion of snapshots in the pool'

  end
  newparam(:snap_harvest_high_threshold) do
    desc 'Snapshot used space high threshold at which the system automatically starts to delete snapshots in the pool'

  end
  newparam(:snap_harvest_low_threshold) do
    desc 'Snapshot used space low threshold below which the system will stop automatically deleting snapshots in the pool'

  end
  newparam(:is_fast_cache_enabled) do
    desc 'Enable/disable FAST Cache for this pool'

  end

  newparam(:is_fastvp_enabled) do
    desc 'Enable/disable scheduled data relocations for this pool.'

  end
  newparam(:pool_type) do
    desc 'Create traditional/dynamic pool'
    defaultto 1

  end

end