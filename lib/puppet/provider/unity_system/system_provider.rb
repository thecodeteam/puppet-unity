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

Puppet::Type.type(:unity_system).provide(:system_provider) do
  @doc = 'Manage Unity system related information.'

  def create
    Puppet.info "[create]Connecting to Unity system #{@resource[:name]}."
    @unity = get_unity_system(@resource)
    Puppet.info "[create]Connected system #{@unity.name}"
  end

  def destroy
    Puppet.info 'Unity System could not be destroyed.'
  end

  def exists?
    Puppet.info "[exists?]checking Unity system #{@resource[:name]}."
    existed = false
    begin
      @unity = get_unity_system(@resource)
      existed = @unity.existed
    rescue => e
      warning "Unable to find unity system #{@resource[:name]}: #{e.message}"
      existed = false
    end
    existed
  end


end
