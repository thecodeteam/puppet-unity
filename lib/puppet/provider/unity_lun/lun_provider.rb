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

Puppet::Type.type(:unity_lun).provide(:lun_provider) do
  @doc = 'Manage Unity LUN.'

  # Needed if there is any *newproperty* defined in type
  mk_resource_methods

  def initialize(*args)
    super *args
    # Define an instance variable that hold values to be synchronized.
    @property_flush = {}
  end

  def create
    Puppet.info 'Creating lun.'
    lun_create
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info 'Destroying lun.'
    lun_destroy
    @property_hash[:ensure] = :absent

  end

  def exists?
    Puppet.info "Checking existence of LUN #{@resource[:name]} ."
    lun = lun_get
    if lun.nil?
      false
    else
      true
    end
  end


  def flush
    Puppet.info 'Flushing LUN info.'
    return if @property_hash[:ensure] == :absent

    @property_hash = lun_property

    Puppet.info "Lun info before flushing #{@property_hash}"

    diff = {}
    @property_hash.each do |key, value|
      if key == :pool
        next
      end
      if @resource[key].nil?
        next
      end
      unless value == @resource[key]
        if key == :compression
          diff[:is_compression] = @resource[key]
        elsif key == :host
          diff[:host_access] = @resource[key]
        elsif key == :thin
          next
        elsif key == :size
          diff[:size] = 21474836480

        else
          diff[key] = @resource[key]
        end
      end
    end

    if diff.empty?
      Puppet.info "NO any change on LUN #{@resource[:name]}"
    else
      Puppet.info "Modifying the LUN with change #{diff}"
      lun = lun_get
      lun.modify!(diff)

    end
  end


  # Instance helpers
  def lun_get
    unity = get_unity_system(resource[:unity_system])
    begin
      lun = unity.get_lun!(name: @resource[:name])
    rescue => e
      Puppet.info("Lun #{@resource[:name]} is not found: #{e.message}")
      return nil
    end
    lun
  end

  def lun_property

    lun = lun_get

    curr = {}

    curr[:name] = lun.name
    curr[:description] = lun.description
    curr[:thin] = lun.is_thin_enabled
    curr[:size] = (lun.size_total / 1024 / 1024 / 1024)
    curr[:host] = lun.host_access
    curr[:pool] = lun.pool.name
    curr[:compression] = lun.is_compression_enabled
    curr[:sp] = lun.default_node.value[0]
    curr[:io_limit_policy] = lun.io_limit_policy

    curr
  end

  def lun_create
    Puppet.info "Creating lun #{@resource[:name]} with size #{@resource[:size]}."

    unity = get_unity_system(@resource[:unity_system])
    pool = @resource[:pool]
    pool = unity.get_pool!(name: pool[:name])
    lun = pool.create_lun!(
      lun_name: @resource[:name],
      size_gb: @resource[:size],
      sp: @resource[:sp],
      host_access: @resource[:host],
      is_thin: @resource[:thin],
      description: @resource[:description],
      io_limit_policy: @resource[:io_limit_policy],
      is_compression: @resource[:compression],
    )
    Puppet.info "LUN created: #{lun.get_id}"
  end

  def lun_destroy
    Puppet.info "Destroying lun #{@resource[:name]}."

    lun = lun_get
    lun_id = lun.get_id
    lun.delete

    Puppet.info "LUN Destroyed: #{lun_id}."
  end


end