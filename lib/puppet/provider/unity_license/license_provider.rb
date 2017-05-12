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

Puppet::Type.type(:unity_license).provide(:license_provider) do
  @doc = 'Manage license upload.'

  def create
    Puppet.info "[License]Beginning uploading Unity license file #{@resource[:licence_file]} for Unity #{@resource[:unity_system]}."

    @unity = get_unity_system(@resource[:unity_system])
    @unity.upload_license(@resource[:license_file].path)
  end

  def destroy
    Puppet.info "License #{@resource[:licence_file]} is not able to remove from Unity system."
  end

  def exists?
    Puppet.info "License #{@resource[:license_file]} cannot be queried."
    # Always force license uploading.
    false
  end
end
