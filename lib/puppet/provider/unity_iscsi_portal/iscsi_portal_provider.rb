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

Puppet::Type.type(:unity_iscsi_portal).provide(:iscsi_portal_provider) do
  @doc = 'Manage iSCSI portal on the Unity ethernet portal.'

  def initialize *args
    @current_property = {}
  end

  def create
    @property_hash[:ensure] = :present
  end

  def destroy
    @property_hash[:ensure] = :absent
  end


  def exists?
    Puppet.info "Checking existence of iSCSI portal #{@resource[:ip]} ."
    unity = get_unity_system(resource[:unity_system])
    begin
      portal = unity.get_iscsi_portal!(
          _id: nil,
          ip_address: @resource[:ip],
          ethernet_port: @resource[:ethernet_port])
    rescue => e
      Puppet.info("iSCSI portal #{@resource[:ip]} is not found: #{e.message}")
      @current_property = {}
      return false
    end

    if portal.__len__ == 0
      @current_property = {}
      return false
    end
    # the first item is the object.
    portal = portal[0]
    @current_property[:ip] = portal.ip_address
    @current_property[:netmask] = portal.netmask
    @current_property[:v6_prefix_len] = portal.v6_prefix_length
    @current_property[:gateway] = portal.gateway
    @current_property[:vlan] = portal.vlan_id
    @current_property[:ethernet_port] = portal.ethernet_port.get_id
    @current_property[:ensure] = :present
    true
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


  def portal_modify(ip, netmask, v6_prefix_len, vlan, gateway)

    Puppet.info "Modifying: #{ip}, #{netmask}, #{v6_prefix_len}, #{vlan}, #{gateway}"
  end


  def portal_destroy
    unity = get_unity_system(resource[:unity_system])

    Puppet.info "Deleting iSCSI portal #{@resource[:ip]}"
    portal = unity.get_iscsi_portal!(ethernet_port: @resource[:ethernet_port],
                                     ip: @resource[:ip])
    portal.delete
    @property_hash[:ensure] = :absent
  end


  def flush
    Puppet.info 'Flushing portal info.'
    case @property_hash[:ensure]
      when :present
        # Modify the current iSCSI Portal
        portal_modify(
            @resource[:ip], @resource[:netmask],
            @resource[:v6_prefix_len], @resource[:vlan],
            @resource[:gateway])
      when :absent
        portal_destroy

    end
  end

end