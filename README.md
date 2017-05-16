# unity

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

The `dellemc-unity` module manages DellEMC Unity storage resources.

The Unity storage system by DellEMC  delivers the ultimate in simplicity and value, enabling your organization to speed
deployment, streamline management and seamlessly tier storage to the cloud. The `dellemc-unity` module allows you to
configure and deploy the Unity via Puppet code.


## Setup

### Requirements

 * Puppet 4.7 or greater
 * Ruby 2.0 or greater
 * rubypython 0.6.3 or greater (The bridge between Ruby and Python)
 * Storops, 0.4.13 or greater (Python storage management library for VNX and Unity.) 


- [rubypython](https://rubygems.org/gems/rubypython) is a bridge between the Ruby and
Python interpreters. It enables the interaction with Python based [storops](https://github.com/emc-openstack/storops)
library, dramatically eases the effort to extend the `dellemc-unity` module.

- [storops](https://github.com/emc-openstack/storops) is a Python storage management library for
VNX and Unity. It needs to be manually installed in Puppet agent/master.

```bash
pip install storops
```

### Installation
Before proceeding, Ensure you have installed the reqiured `Ruby` and `Puppet`.
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

## Reference

### Types

 * `unity_system`: Define a Unity system.
 * `unity_license`: Upload a license to a defined Unity system.
 * `unity_pool`: Create, update, or destroy a storage pool.



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
  raid_groups  => [{
    disk_group   => 'dg_15',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }, {
    disk_group   => 'dg_16',
    raid_type    => 1,
    stripe_width => 0,
    disk_num     => 5,
  }]
...
```

`disk_group`: the id of disk group of the Unity system.


`raid_type`: the raid type of pool.


Valid values are:
- `0`: None
- `1`: RAID5
- `2`: RAID0
- `3`: RAID1
- `4`: RAID3
- `7`: RAID10
- `10`: RAID6
- `48879`: Automatic

`stripe_width`: RAID group stripe widths, including parity or mirror disks.

- `0` : BestFit value is used in automatic selection of stripe configuration.
- `2`: A 2 disk group, usable in RAID10 1+1 configuration.
- `4`: A 4 disk group, usable in RAID10 2+2 configuration.
- `5`: A 5 disk group, usable in RAID5 4+1 configuration.
- `6`: A 6 disk group, usable in RAID6 4+2 and RAID10 3+3 configurations.
- `8`: A 8 disk group, usable in RAID6 6+2 and RAID10 4+4 configurations.
- `9`: A 9 disk group, usable in RAID5 8+1 configuration.
- `10`: A 10 disk group, usable in RAID6 8+2 and RAID10 5+5 configurations.
- `12`: A 12 disk group, usable in RAID6 10+2 and RAID10 6+6 configurations.
- `13`: A 13 disk group, usable in RAID5 12+1 configuration.
- `14`: A 14 disk group, usable in RAID6 12+2 configuration.
- `15`: raid strip width including parity disks, can be used in RAID6 14+2 configuration.


`disk_num`: Number of disks.
 
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