# unity

#### Table of Contents

1. [Overview](#description)
1. [Setup - The basics of getting started with unity](#setup)
    * [What unity affects](#what-unity-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with unity](#beginning-with-unity)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

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


### Beginning with unity

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference


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

## Limitations

TODO

## Development

Simply fork the repo [puppet-unity](https://github.com/emc-openstack/puppet-unity) and send PR for your code change(also provide testing result of your change), remember to give a title and description of your PR. 

## Contributors

peter.wang13 at emc.com


## Release Notes

0.1.0 - Initial release.