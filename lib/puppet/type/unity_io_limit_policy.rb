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

Puppet::Type.newtype(:unity_io_limit_policy) do
  @doc = 'Configure DellEMC Unity io limit policy.'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'I/O limit rule name.'
  end

  newproperty(:policy_type) do
    desc 'Indicates whether the I/O limit policy is absolute or density-based.'
  end
  newproperty(:description) do
    desc 'I/O limit rule description.'

  end

  newproperty(:max_iops) do
    desc 'Read/write IOPS limit.'
  end

  newproperty(:max_kbps) do
    desc 'Read/write KB/s limit.'
  end

  newproperty(:max_iops_density) do
    desc 'Read/write density-based IOPS limit.'
  end

  newproperty(:max_kbps_density) do
    desc 'Read/write density-based KB/s limit.'
  end

  newproperty(:luns,  :arrray_matching => :all) do
    desc 'LUNs for applying this io policy'
  end
end
