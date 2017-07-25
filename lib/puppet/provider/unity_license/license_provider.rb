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

Puppet::Type.type(:unity_license).provide(:license_provider) do
  @doc = 'Manage license upload.'

  def create
    Puppet.info "[License]Beginning uploading Unity license file #{@resource[:license_file]} for Unity #{@resource[:unity_system]}."

    unity = get_unity_system(@resource[:unity_system])
    unity.upload_license(@resource[:license_file].to_s)

  end

  def destroy
    Puppet.info "License #{@resource[:licence_file]} is not able to remove from Unity system."
  end

  def exists?
    Puppet.info "Checking existence of License #{@resource[:license_file]}."
    # Always force license uploading.
    is_license_same? @resource[:license_file].to_s
  end


  def get_file_info(path)
    feature_names = []
    File.open(path, 'r') do |license|
      while (line = license.gets)
        if line.include? 'INCREMENT'
          f_name = line.split[1]
          feature_names << f_name
        end
      end

      return feature_names
    end
  end

  def get_array_licenses
    license_names = []
    unity = get_unity_system(@resource[:unity_system])
    licenses = unity.get_license
    licenses.to_enum.each do |license|
      license_names << license.name.to_s
    end

    license_names

  end

  def is_license_same?(path)
    curr = get_array_licenses
    file_lic = get_file_info path
    if curr.to_set == file_lic.to_set
      Puppet.debug "No change in #{path}. Skipping license uploading."
      return true
    else
      Puppet.info "New changes found in #{path}, uploading changes: #{(file_lic.to_set - curr.to_set).to_a}."
      return false
    end
  end

end
