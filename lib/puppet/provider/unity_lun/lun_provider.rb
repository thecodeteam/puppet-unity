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

    unity = get_unity_system(@resource[:unity_system])
    lun = lun_get
    @property_hash = lun_property lun

    Puppet.info "Lun info before flushing #{@property_hash}"

    diff = {}
    @property_hash.each do |key, value|
      # Thin/pool cannot be changed
      if key == :pool || key == :thin
        next
      end
      if key == :io_limit_policy
        # compare policy name
        if @resource[key].nil? && value.nil? != true
          # user want to remove lun from the policy
          policy = unity.get_io_limit_policy!(name: value)
          remove_from_policy(policy, lun)
        end
        if @resource[key].nil? != true && value.nil?
          # user want to add lun to the policy
          policy = unity.get_io_limit_policy!(name: @resource[key][:name])
          add_to_policy(policy, lun)
        end
        next
      end

      if key == :hosts
        # Compare hosts
        new_names = []
        unless @resource[key].nil?
          # clear the hosts for the LUN
          new_names = []
          Puppet.info "key: #{@resource[key]}"

          @resource[key].each do |host_res|
            Puppet.info "Resource #{host_res}"
            new_names << resource.catalog.resource(host_res.to_s)[:name]
          end
        end
        new_names = new_names.to_set

        curr_names = value.to_set
        if curr_names == new_names
          Puppet.debug "No change for the hosts of LUN #{lun.name}."
        else
          Puppet.info "Setting new hosts #{new_names.to_a} for LUN #{lun.name}."
          lun.update_host!(host_names: new_names.to_a)
        end

      end

      if @resource[key].nil?
        next
      end
      unless value == @resource[key]
        if key == :compression
          diff[:is_compression] = @resource[key]
        elsif key == :size
          # TODO need to resolve the long bug in rubypython
          diff[:size] = @resource[key] * 1024 * 1024 * 1024
        else
          diff[key] = @resource[key]
        end
      end

    end # end_of_each

    unless diff.empty?
      Puppet.info "Modifying the LUN properties with change #{diff}"
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

  def lun_property lun
    if lun.nil?
      lun = lun_get
    end
    curr = {}

    curr[:name] = lun.name
    curr[:description] = lun.description
    curr[:thin] = lun.is_thin_enabled
    curr[:size] = (lun.size_total / 1024 / 1024 / 1024)
    curr[:hosts] = get_current_hosts(lun)
    curr[:pool] = lun.pool.name
    curr[:compression] = lun.is_compression_enabled
    curr[:sp] = lun.default_node.value[0]
    if lun.io_limit_policy == nil
      curr[:io_limit_policy] = nil
    else
      curr[:io_limit_policy] = lun.io_limit_policy.name
    end
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
      # host_access: @resource[:host],
      is_thin: @resource[:thin],
      description: @resource[:description],
      # io_limit_policy: @resource[:io_limit_policy],
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

  # Manage policy and lun relationship
  def add_to_policy(policy, lun)
    Puppet.info "Adding policy #{policy.name} to lun #{lun.name}."
    policy.apply_to_storage(lun)
  end

  def remove_from_policy(policy, lun)
    Puppet.info "Removing policy #{policy.name} from lun #{lun.name}."
    policy.remove_from_storage(lun)
  end

  # Manage host and lun relationship
  def update_hosts(lun, host_names)
    Puppet.info "Updating hosts for lun #{lun.name}."
    lun.update_hosts(host_names)
  end

  def get_current_hosts(lun)
    unity = get_unity_system(@resource[:unity_system])
    host_names = []
    unless lun.host_access == nil
      host_ids = lun.host_access.get_host_id

      host_ids.each do |host_id|
        host = host_get_by_id unity, host_id
        host_names << host.name
      end
    end
    host_names
  end

  def host_get_by_id(unity, host_id)
    unity.get_host!(_id: host_id)
  end


end