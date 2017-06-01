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

Puppet::Type.newtype(:unity_host) do
  @doc = 'Configure DellEMC Unity host.'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name for creating the host.'
  end

  newparam(:host_type) do
    desc 'Type for the host, can be 0, 1, 2, 3, 4, 5'

    defaultto 1

  end

  newproperty(:description) do
    desc 'Description for the host.'
  end

  newproperty(:os) do
    desc 'Operating system running on the host.'
  end

  # We haven't add
  # newproperty(:tenant) do
  #   desc 'Tenant with which the host is to be associated.'
  # end

  newproperty(:ip) do
    desc 'IP address for the host.'
  end

  newproperty(:iqn) do
    desc "Initiator's IQN for the host."
  end

  newproperty(:wwns, :array_matching => :all) do
    desc 'WWNs for the host.'
  end
end
