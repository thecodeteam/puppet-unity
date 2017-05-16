# unity

#### Table of Contents

1. [Overview](#description)
1. [Setup](#setup)
    * [Requirements](#setup-requirements)
    * [Beginning with unity](#beginning-with-unity)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

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

[rubypython](https://rubygems.org/gems/rubypython) is a bridge between the Ruby and
Python interpreters. It enables the interaction with Python based [storops](https://github.com/emc-openstack/storops)
library, dramatically easing the effort to extend the `dellemc-unity` module from `storops`.

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