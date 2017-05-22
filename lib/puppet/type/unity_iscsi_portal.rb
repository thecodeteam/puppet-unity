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

Puppet::Type.newtype(:unity_iscsi_portal) do
  @doc = 'Configure DellEMC Unity iSCSI portal.'
  ensurable

  newparam(:ip, :namevar => true) do
    desc 'ip address for the iSCSI portal.'
  end

  newproperty(:ethernet_port) do
    desc 'Ethernet port for creating the iSCSI portal.'
  end

  newproperty(:netmask) do
    desc 'Netmask for the iSCSI portal.'
  end

  newproperty(:v6_prefix_len) do
    desc 'IP v6 prefix'
  end

  newproperty(:vlan) do
    desc 'VLAN id.'
  end

  newproperty(:gateway) do
    desc 'Gateway of network.'
  end
end