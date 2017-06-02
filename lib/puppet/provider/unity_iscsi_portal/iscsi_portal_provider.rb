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

Puppet::Type.type(:unity_iscsi_portal).provide(:iscsi_portal_provider) do
  @doc = 'Manage iSCSI portal on the Unity ethernet portal.'

  # Needed if there is any *newproperty* defined in type
  mk_resource_methods

  def initialize(*args)
    super *args
    # Define an instance variable that hold values to be synchronized.
    @property_flush = {}
  end

  def create
    Puppet.info "Creating portal"
    portal_create
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info "Destroying portal"
    portal_destroy
    @property_hash[:ensure] = :absent
  end


  def exists?
    Puppet.info "Checking existence of iSCSI portal #{@resource[:ip]} ."
    if portal_get == nil
      false
    else
      true
    end
  end

  def flush
    Puppet.info 'Flushing portal info.'
    set_portal

    # @property_hash = portal_property
  end

  def set_portal
    return if @property_hash[:ensure] == :absent

    @property_hash = portal_property
    # We need to recreate the portal if its underlying ethernet_port get changed
    if @property_hash[:ethernet_port] != @resource[:ethernet_port]
      portal_destroy
      portal_create
      return
    else
      diff = {}
      @property_hash.each do |key, value|
        if key == :ensure
          next
        end
        if key == :ethernet_port
          next
        end
        unless value == @resource[key]
          if @resource[key].nil?
            next
          end
          diff[key] = @resource[key]
        end
      end
    end

    if diff.empty?
      Puppet.info "NO any change on portal #{@resource[:ip]}"
    else
      portal_modify(diff)
    end
  end

  # @property_hash = portal_property


  def portal_property
    unity = get_unity_system(@resource[:unity_system])
    portal = unity.get_iscsi_portal!(
      _id: nil,
      ip_address: @resource[:ip])
    if portal.__len__ == 0
      return {:ensure => :absent}
    else
      # the first item is the object.
      portal0 = portal[0]
      convert_portal(portal0)
    end
  end


  def portal_create
    unity = get_unity_system(resource[:unity_system])

    Puppet.info "Creating iSCSI portal #{@resource[:ip]}."
    portal = unity.create_iscsi_portal!(
      ethernet_port: @resource[:ethernet_port],
      ip: @resource[:ip], netmask: @resource[:netmask],
      v6_prefix_len: @resource[:v6_prefix_len],
      vlan: @resource[:vlan],
      gateway: @resource[:gateway])
    Puppet.info "Created iSCSI portal #{@resource[:ip]}."
    @property_hash[:ensure] = :present
  end

  def portal_modify(diff)
    Puppet.info "Modifying: #{@resource}"
    portal = portal_get
    # No way to update the ip on created portal.
    portal.modify!(diff)
  end

  def portal_destroy
    Puppet.info "Deleting iSCSI portal #{@resource[:ip]}"
    portal = portal_get
    portal.delete
    @property_hash[:ensure] = :absent
  end


  def portal_get
    unity = get_unity_system(@resource[:unity_system])
    Puppet.info "Getting iSCSI portal #{@resource[:ip]}"
    portal = unity.get_iscsi_portal!(
      _id: nil,
      ip_address: @resource[:ip])
    if portal.__len__ == 0
      nil
    else
      # the first item is the object.
      portal = portal[0]
      portal
    end
  end

  def convert_portal(portal)
    current_property = {}
    current_property[:ip] = none_to_nil(portal.ip_address)
    current_property[:netmask] = none_to_nil(portal.netmask)
    current_property[:v6_prefix_len] = none_to_nil(portal.v6_prefix_length)
    current_property[:gateway] = none_to_nil(portal.gateway)
    current_property[:vlan] = none_to_nil(portal.vlan_id)
    current_property[:ethernet_port] = none_to_nil(portal.ethernet_port.get_id)
    current_property[:ensure] = :present
    current_property
  end

end
