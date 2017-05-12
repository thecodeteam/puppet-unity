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

class unity::pool (
  $unity_system,
  $description,
  $raid_groups,
  $alert_threshold = undef,
  $is_harvest_enabled = undef,
  $is_snap_harvest_enabled = undef,
  $pool_harvest_high_threshold = undef,
  $pool_harvest_low_threshold = undef,
  $snap_harvest_high_threshold = undef,
  $snap_harvest_low_threshold = undef,
  $is_fast_cache_enabled = undef,
  $is_fastvp_enabled = undef,
  $pool_type = undef,
) {
  unity_pool { $name:
    unity_system                => $unity_system,
    description                 => $description,
    raid_groups                 => $raid_groups,
    alert_threshold             => $alert_threshold,
    is_harvest_enabled          => $is_harvest_enabled,
    is_snap_harvest_enabled     => $is_snap_harvest_enabled,
    pool_harvest_high_threshold => $pool_harvest_high_threshold,
    pool_harvest_low_threshold  => $pool_harvest_low_threshold,
    snap_harvest_high_threshold => $snap_harvest_high_threshold,
    snap_harvest_low_threshold  => $snap_harvest_low_threshold,
    is_fast_cache_enabled       => $is_fast_cache_enabled,
    is_fastvp_enabled           => $is_fastvp_enabled,
    pool_type                   => $pool_type,
  }

}