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

Puppet::Type.type(:unity_io_limit_policy).provide(:io_limit_policy_provider) do
  @doc = 'Manage io limit policy for Unity storage.'

  mk_resource_methods

  def create
    Puppet.info 'Creating io policy.'
    policy_create
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info 'Destroying io policy.'
    policy_destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.info "Checking existence of io policy #{@resource[:name]} ."
    if policy_get.nil?
      false
    else
      true
    end
  end

  def flush
    Puppet.info 'Flushing io policy info.'
    return if @property_hash[:ensure] == :absent

    @property_hash = policy_property

    Puppet.info "IO policy info before flushing #{@property_hash}."

    diff = {}
    @property_hash.each do |key, value|
      unless value == @resource[key]
        if @resource[key].nil?
          next
        end
        diff[key] = @resource[key]
      end
    end

    if diff.empty?
      Puppet.info "No change made on policy #{@resource[:name]}."
    else
      Puppet.info "Setting new changes #{diff} on policy #{@resource[:name]}."
      policy_modify diff
    end
  end

  # instance methods
  def policy_create
    unity = get_unity_system(resource[:unity_system])
    Puppet.info "Creating policy #{@resource[:name]}"

    policy = unity.create_io_limit_policy!(
      name: @resource[:name],
      max_iops: @resource[:max_iops],
      max_kbps: @resource[:max_kbps],
      policy_type: @resource[:policy_type],
      description: @resource[:description],
      max_iops_density: @resource[:max_iops_density],
      max_kbps_density: @resource[:max_kbps_density],
      burst_rate: @resource[:burst_rate],
      burst_time: @resource[:burst_time],
      burst_frequency: @resource[:burst_frequency],

    )

    Puppet.info "Policy #{policy.get_id} created."

  end

  def policy_get
    unity = get_unity_system(resource[:unity_system])
    Puppet.info "Getting policy #{@resource[:name]}"

    begin
      policy = unity.get_io_limit_policy!(name: @resource[:name])
    rescue => e
      Puppet.info "Policy #{@resource[:name]} is not found: #{e.message}"
      policy = nil
    end
    policy
  end


  def policy_property

    policy = policy_get

    current_property = {}
    current_property[:name] = policy.name
    current_property[:description] = policy.description
    current_property[:policy_type] = policy.type.value[0]
    unless policy.io_limit_rule_settings.nil?
      current_property[:max_iops] = policy.io_limit_rule_settings[0].max_iops
      current_property[:max_kbps]= policy.io_limit_rule_settings[0].max_kbps
      current_property[:max_iops_density]= policy.io_limit_rule_settings[0].max_iops_density
      current_property[:max_kbps_density]= policy.io_limit_rule_settings[0].max_kbps_density
      current_property[:burst_rate] = policy.io_limit_rule_settings[0].burst_rate
      current_property[:burst_time] =policy.io_limit_rule_settings[0].burst_time
      current_property[:burst_frequency] = policy.io_limit_rule_settings[0].burst_frequency
    else
      current_property[:max_iops] = nil
      current_property[:max_kbps] = nil
      current_property[:max_iops_density] = nil
      current_property[:max_kbps_density] = nil
      current_property[:burst_rate] = nil
      current_property[:burst_time] = nil
      current_property[:burst_frequency] =nil
    end
    current_property
  end

  def policy_modify diff
    policy = policy_get
    policy.modify!(diff)

  end

  def policy_destroy
    policy = policy_get

    policy.delete
  end

end