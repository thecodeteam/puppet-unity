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
require 'puppet/util/dellemc/resource'

Puppet::Type.type(:unity_pool).provide(:pool_provider) do
  @doc = 'Manage Unity system related information.'

  def create
    Puppet.info "Creating pool #{@resource[:name]}."
    res = resource.catalog.resource(resource[:unity_system].to_s)
    @unity = get_unity_system(res)

    params = get_raid_group_parameters(@resource[:raid_groups])
    @unity.create_pool(@resource[:name], params, resource[:description],
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
  end

  def destroy
    Puppet.warn "Unity system #{@resource[:name]} cannot be destroyed"
  end

  def exists?
    Puppet.info "Checking existence of pool #{@resource[:name]} ."
    res = resource.catalog.resource(resource[:unity_system].to_s)
    @unity = get_unity_system(res)
    begin
      pool = @unity.get_pool(nil, @resource[:name])
    rescue => e
      Puppet.info("Pool #{@resource[:name]} is not found: #{e.message}")
      pool = nil
    end

    if pool == nil
      return false
    end
    true
  end
end

