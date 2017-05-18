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

Puppet::Type.newtype(:unity_lun) do
  @doc = 'Configure DellEMC Unity LUN.'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'Unique identifier for the Unity LUN.'
  end

  newparam(:description) do
    desc 'LUN description.'
    defaultto do
      ''
    end
  end

  newproperty(:size) do
    desc 'set LUN size.'
    validate do |value|
      raise(Puppet.Error, 'The LUN size can not be empty.') if value == nil
      unless value.is_a? Integer
        raise(Puppet.Error, 'The LUN size must be a integer.')
      end
    end
  end

  newparam(:thin) do
    desc 'Enable/disable thin provisiontioning.'

    defaultto true
    newvalues(true, false)
  end

  newproperty(:compression) do
    desc 'Enable/disable LUN compression.'

    defaultto true
    newvalues(true, false)
  end

  newproperty(:default_node) do
    desc 'Storage Processor (SP) that owns the LUN.'

    newvalues(0, 1, nil)
  end

  newproperty(:host_access) do
    desc 'Host access settings for the LUN, as defined by the blockHostAccess embedded resource type.'

  end

  newproperty(:io_limit) do
    desc 'IO limit settings for the LUN, as defined by the ioLimitParameters.'
  end

end