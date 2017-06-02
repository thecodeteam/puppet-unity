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


Puppet::Type.type(:unity_host).provide(:host_provider) do
  @doc = 'Manage iSCSI portal on the Unity ethernet portal.'

  # Needed if there is any *newproperty* defined in type
  mk_resource_methods

  def create
    Puppet.info 'Creating host.'
    host_create
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info 'Destroying host.'
    host_destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.info "Checking existence of host #{@resource[:name]} ."
    if host_get.nil?
      false
    else
      true
    end
  end

  def flush
    Puppet.info 'Flushing host info.'
    return if @property_hash[:ensure] == :absent

    @property_hash = host_property

    Puppet.info "Host info before flushing #{@property_hash}"
    diff = {}
    @property_hash.each do |key, value|
      Puppet.info "Comparing #{value} and #{@resource[key]}"
      unless value == @resource[key]
        if @resource[key].nil?
          next
        end
        diff[key] = @resource[key]
      end
    end

    if diff.empty?
      Puppet.info "No any change on host #{@resource[:name]}"
    else
      Puppet.debug "The change for host is: #{diff}"
      host_destroy
      host_create
    end

  end

  #### instance method

  def host_create
    unity = get_unity_system(resource[:unity_system])
    Puppet.info "creating host #{@resource[:name]}"
    host = unity.create_host!(
      name: @resource[:name],
      host_type: @resource[:host_type],
      desc: @resource[:description],
      os: @resource[:os])

    unless @resource[:iqn].nil?
      host.add_initiator!(@resource[:iqn])
    end

    unless @resource[:wwns].nil?
      @resource[:wwns].each do |wwn|
        host.add_initiator!(wwn)
      end
    end

    unless @resource[:ip].nil?
      host.add_ip_port!(@resource[:ip])
    end

  end

  def host_destroy
    Puppet.info "Deleting host #{@resource[:name]} and its related resources."
    host = host_get

    if host.nil?
      Puppet.info "Host #{@resource[:name]} was already destroyed."
    else
      host.delete
    end
  end

  def host_get
    unity = get_unity_system(resource[:unity_system])
    Puppet.info "Getting host #{@resource[:name]}"
    begin
      host = unity.get_host!(name: @resource[:name])
    rescue => e
      Puppet.info("Host #{@resource[:name]} is not found: #{e.message}")
      host = nil
    end
    host
  end

  def host_property
    host = host_get
    current_property = {}
    current_property[:name] = host.name
    current_property[:host_type] = host.type.value[0]
    current_property[:description] = host.description
    current_property[:os] = host.os_type
    if host.host_ip_ports == nil
      current_property[:ip] = nil
    else
      current_property[:ip] = host.host_ip_ports[0].address
    end
    if host.iscsi_host_initiators == nil
      current_property[:iqn] = nil
    else
      current_property[:iqn] = host.iscsi_host_initiators[0].initiator_id
    end
    if host.fc_host_initiators == nil
      current_property[:wwns] = nil
    else
      current_property[:wwns] = host.fc_host_initiators.initiator_id

    end

    current_property
  end


end
