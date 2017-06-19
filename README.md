# Puppet module for Unity system

#### Table of Contents

- [Overview](#description)
- [Setup](#setup)
    * [Requirements](#requirements)
    * [Installation](#Installation)
- [Usage](#usage)
- [Reference](#reference)
    * [Types](#types)
    * [Parameters](#parameters)
- [Limitations](#limitations)
- [Development](#development)
- [Contributors](#contributors)
- [Contact](#contact)
- [Release-notes](#release-notes)

## Overview

The `puppet-unity` module manages DellEMC Unity storage resources.

The Unity storage system by DellEMC delivers the ultimate in simplicity and value, enabling your organization to speed
deployment, streamline management and seamlessly tier storage to the cloud. The `puppet-unity` module allows you to
configure and deploy the Unity via Puppet code.


## Setup

### Requirements

 * Puppet 4.7 or greater
 * Ruby 2.0 or greater
 * rubypython 0.6.3 or greater (The bridge between Ruby and Python)
 * Storops, 0.4.15 or greater (Python storage management library for Unity and VNX.)


- [rubypython](https://rubygems.org/gems/rubypython) is a bridge between the Ruby and
Python interpreters. It enables the interaction with Python based [storops](https://github.com/emc-openstack/storops)
library, dramatically eases the effort to extend the `puppet-unity` module.

- [storops](https://github.com/emc-openstack/storops) is a Python storage management library for
VNX and Unity. It needs to be manually installed in Puppet agent/master.

```bash
pip install storops
```

### Installation
Before proceeding, Ensure you have installed the required `Ruby` and `Puppet`.
1. Install `rubypython` via gem
```bash
gem install rubypython
```

2. Install `storops` from [pypi](https://pypi.python.org/pypi)
```bash
pip install storops
```
## Usage

* Define a managed Unity system

```puppet
unity_system { 'FNM00150600267':
  ip       => '10.245.101.35',
  user     => 'admin',
  password => 'Password123!',
  ensure => present,
}
```

The defined system `Unity_system['FNM00150600267']` then can be passed to any Unity resources.

* Upload a license

```puppet
unity_license{ '/path/to/the/license.lic':
  unity_system => Unity_system['FNM00150600267'],
  ensure => present,
}
```

Note: the path separator in the `title` must be `/` even using on Windows agent.
* Create a pool

```puppet
unity_pool { 'puppet_pool':
  unity_system => Unity_system['FNM00150600267'],
  description => 'created by puppet module',
  raid_groups => [{
    disk_group => 'dg_15',
    raid_type => 1,
    stripe_width => 0,
    disk_num => 5,
  }],
  ensure => present,
}
```

* Create a iSCSI portal on ethernet port

```puppet
unity_iscsi_portal { '10.244.213.245':
  unity_system  => Unity_system['FNM00150600267'],
  ethernet_port => 'spa_eth3',
  netmask       => '255.255.255.0',
  vlan          => 133,
  gateway       => '10.244.213.1',
  ensure        => present,
}
```

* Create a Host

```puppet
unity_host { 'my_host':
  unity_system => Unity_system['FNM00150600267'],
  description  => 'Created by puppet',
  ip           => '192.168.1.139',
  os           => 'Ubuntu16',
  host_type    => 1,
  iqn          => 'iqn.1993-08.org.debian:01:unity-puppet-host',
  wwns         => ['20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D3',
     '20:00:00:90:FA:53:4C:D1:10:00:00:90:FA:53:4C:D4'],
  ensure       => present,
}
```

* Create a io limit policy

```puppet
# Create a Unity io limit policy (absolute limit)
unity_io_limit_policy { 'puppet_policy':
  unity_system => Unity_system['FNM00150600267'],
  policy_type => 1,
  description => 'Created by puppet 12',
  max_iops => 1000,
  max_kbps => 20480,
  burst_rate => 50,
  burst_time => 10,
  burst_frequency => 2,
}
```

The meaning for above burst settings is: **50% for 10 minute(s) resetting every 2 hour(s)**.

* Create a LUN

```puppet
unity_lun { 'puppet_lun':
  unity_system    => Unity_system['FNM00150600267'],
  pool            => Unity_pool['puppet_pool'],
  size            => 15,
  thin            => true,
  compression     => false,
  sp              => 0,
  description     => "Created by puppet_unity.",
  io_limit_policy => Unity_io_limit_policy['puppet_policy'],
  hosts           => [Unity_host['my_host']],
  ensure          => present,
}
```


## Reference

### Types

 * `unity_system`: Define a Unity system.
 * `unity_license`: Upload a license to a defined Unity system.
 * `unity_pool`: Create, destroy a storage pool.
 * `unity_iscsi_portal`: Create, update, or destroy a iSCSI portal. Applicable for both IPv4 and IPv6.
 * `unity_host`: Create, update, or destroy a Unity host
 * `unity_io_limit_policy`: Create, update, or destroy a Unity IO limit policy
 * `unity_lun`: Create, update, or destroy a Unity LUN

You can reference the examples for each resource type under the source code folder [examples](puppet-exampels)

### Parameters

#### Type: `unity_system`

##### `name`
Optional.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `ip`

Required. 

The management IP of Unity.
##### `username`

Required. 

The username of Unity.
##### `password`

Required. 

The password of Unity.

#### Type: `unity_license`

##### `license_file`
Optional.

THe absolute path of the license file.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `unity_system`
Required. 

The Unity system reference.

##### `ensure`
Required. 

`present` will upload the license for the referenced Unity system.

#### Type: `unity_pool`

##### `name`
Optional.

The name of the pool.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `ensure`
Required.

`present` will create the pool if absent.
`absent` will delete the pool if present

##### `description`

Optional.

The description of the pool.

##### `raid_groups`

Required.

a list of `Hash` is required for the pool.
```puppet
...
unity_pool { 'puppet_pool':
  unity_system => Unity_system['FNM00150600267'],
  description  => 'created by puppet module',
  raid_groups  => [{
    disk_group   => 'dg_15',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }],
  alert_threshold => 80,
  is_snap_harvest_enabled => true,
  is_harvest_enabled => true,
  ensure       => present,
}
...
```
Parameters in `raid_groups`:

 * `disk_group`: the id of disk group of the Unity system.


 * `raid_type`: the raid type of pool.


Valid values are:

| Value   | Description |
|---------|-------------|
| `0`     | None        |
| `1`     | RAID5       |
| `2`     | RAID0       |
| `3`     | RAID1       |
| `4`     | RAID3       |
| `7`     | RAID10      |
| `10`    | RAID6       |
| `48879` | Automatic   |

 * `stripe_width`: RAID group stripe widths, including parity or mirror disks.

| Value | Description                                                                       |
|-------|-----------------------------------------------------------------------------------|
| `0`   | BestFit value is used in automatic selection of stripe configuration.             |
| `2`   | A 2 disk group, usable in RAID10 1+1 configuration.                               |
| `4`   | A 4 disk group, usable in RAID10 2+2 configuration.                               |
| `5`   | A 5 disk group, usable in RAID5 4+1 configuration.                                |
| `6`   | A 6 disk group, usable in RAID6 4+2 and RAID10 3+3 configurations.                |
| `8`   | A 8 disk group, usable in RAID6 6+2 and RAID10 4+4 configurations.                |
| `9`   | A 9 disk group, usable in RAID5 8+1 configuration.                                |
| `10`  | A 10 disk group, usable in RAID6 8+2 and RAID10 5+5 configurations.               |
| `12`  | A 12 disk group, usable in RAID6 10+2 and RAID10 6+6 configurations.              |
| `13`  | A 13 disk group, usable in RAID5 12+1 configuration.                              |
| `14`  | A 14 disk group, usable in RAID6 12+2 configuration.                              |
| `15`  | raid strip width including parity disks, can be used in RAID6 14+2 configuration. |


 * `disk_num`: Number of disks.
 
##### `alert_threshold`


Optional.

Threshold at which the system will generate alerts about the free space in the pool, specified as a percentage.

##### `is_harvest_enabled`
Optional

Enable/disable pool harvesting.

##### `is_snap_harvest_enabled`
Optional

Enable/disable pool snapshot harvesting.


##### `is_harvest_enabled`
Optional

Enable/disable pool harvesting.

##### `pool_harvest_high_threshold`

Optional

Pool used space high threshold at which the system will automatically starts to delete snapshots in the pool.

##### `pool_harvest_low_threshold`
Optional

Pool used space low threshold under which the system will automatically stop deletion of snapshots in the pool.

##### `snap_harvest_high_threshold`
Optional

Snapshot used space high threshold at which the system automatically starts to delete snapshots in the pool.

##### `snap_harvest_low_threshold`
Optional

Snapshot used space low threshold below which the system will stop automatically deleting snapshots in the pool.

##### `is_fast_cache_enabled`
Optional

Enable/disable FAST Cache for this pool

##### `is_fastvp_enabled`
Optional

Enable/disable scheduled data relocations for this pool.

##### `pool_type`
Optional

Create traditional/dynamic pool


#### Type: `unity_iscsi_portal`

##### `ip`

Required

IP of the iSCSI portal

##### `ethernet_port`

Required

The ethernet port ID for the iSCSI portal.

such as `spa_eth2`, `spb_eth3`.

##### `netmask`

Required 

The netmask for the iSCSI portal

It can be a address `255.255.255.0` or a length `24`.

##### `vlan`

Required 
The VLAN identifier for the iSCSI portal.

##### `gateway`

Optional

The gateway for the network. the gateway must be reachable during creation.


##### `v6_prefix_len`

Optional

IPv6 prefix length for the interface, if it uses an IPv6 address.

#### Type: `unity_host`

##### `name`
Optional.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `host_type`
Optional.

Valid values are:

| value | Description                                                                                                  |
|-------|--------------------------------------------------------------------------------------------------------------|
| `0`   | Host configuration is unknown.                                                                               |
| `1`   | A manually defined individual host system.                                                                   |
| `2`   | All the hosts in a subnet.                                                                                   |
| `3`   | A netgroup, used for NFS access. Netgroups are defined by NIS, and only available when NIS is active.        |
| `4`   | A RecoverPoint appliance host.                                                                               |
| `5`   | An auto-managed host - the system or an external agent identifies and updates the information for this host. |
| `255` | Host defined for Block Migration from VNX Platform system.                                                   |

Default to `1`

##### `description`
Optional.

Description for the host.

##### `os`
Optional.

Operating system running on the host.

##### `ip`
Required.

IP address for the host.

##### `iqn`
Optional.

Initiator's IQN for the host.

##### `wwns`

Optional.

WWNs for the host.


#### Type: `unity_io_limit_policy`

##### `name`
Optional.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `policy_type`
Optional.

Indicates whether the I/O limit policy is absolute or density-based.

Valid values are:

| value | Description         |
|-------|---------------------|
| `1`   | Absolute Value      |
| `2`   | Density-based Value |


Default to `1`.

##### `description`
Optional.

I/O limit rule description.

##### `max_iops`
Optional.

Read/write IOPS limit.

##### `max_kbps`
Optional.

Read/write KB/s limit.

##### `max_iops_density`
Optional.

Read/write density-based IOPS limit.

##### `max_kbps_density`

Optional.
Read/write density-based KB/s limit.

##### `burst_rate`
optional.
The percentage of read/write IOPS and/or KBPS over the limits a storage object is allowed to process during a spike in demand.

##### `burst_time`
optional.
How long a storage object is allowed to process burst traffic.

burst_time must be `1` to `60`.

##### `burst_frequency`
optional.

How often a storage object is allowed to process burst traffic for the duration of burst time.

burst_frequency must be `1` to `24`.
#### Type: `unity_lun`

##### `name`
Optional.

If not specified when declaring a resource,
its value will default to the `title` of the resource.

##### `description`
Optional.

LUN description.

##### `thin`
Optional.

Enable/disable thin provisioning.

Valid values are:

- `true`: Enable thin.
- `false`: Disable thin.

Default to `true`.

##### `size`
Required.

Specify LUN size in gagabyte.


##### `pool`
Required.

Set pool of the LUN.

##### `compression`
Optional.

Enable/disable LUN compression, only applicable for all-flash pool.


##### `sp`
Optional.

Storage Processor (SP) that owns the LUN.

Valid values are:

| value | Description |
|-------|-------------|
| `0`   | SPA         |
| `1`   | SPB         |


##### `io_limit_policy`
Optional.

IO limit settings for the LUN.

##### `hosts`
Optional.

Hosts which contain this LUN.


## Limitations

TODO

## Development

Simply fork the repo [puppet-unity](https://github.com/emc-openstack/puppet-unity) and send PR for your code change(also provide testing result of your change), remember to give a title and description of your PR. 

## Contributors

peter.wang13 at emc.com

## Contract

peter.wang13 at emc.com

## Release Notes

0.1.0 - Initial release.