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

Puppet::Type.newtype(:unity_system) do
  @doc = 'Configure the DellEMC Unity storage system.'

  ensurable

  def self.instances
    # this code is here to support purging and the query-all functionality of the
    # 'puppet resource' command, such as:
    # 'puppet resource unity_system  test ip=192.168.1.50 user=admin password=password'
    if self.respond_to?(:ip, :user, :password)
      # figure out what to do about the separator
      Puppet.info("IP :#{ip}, USER: #{user}, PASSWORD: #{password}")
      unity = get_unity_system({:ip => ip, :user => user, :password => password})
      resources = []
      resources.push(
          unity_system.new(name => unity.name, ip => unity.ip, user => unity.user)
      )
      resources
    else
      raise(Puppet::Error, 'Unable to locate Unity system.')
    end
  end

  newparam(:name, :namevar => true) do
  end

  newparam(:ip) do

  end

  newparam(:user) do

  end

  newparam(:password) do
  end

  newparam(:cacertfile) do

  end

  unless Puppet::Type.metaparams.include? :unity_system
    Puppet::Type.newmetaparam(:unity_system) do
      desc 'Provide a global metaparameter for all Unity resources.'
      Puppet.info 'Initialize new Unity system newmetaparam.'
    end
  end
end