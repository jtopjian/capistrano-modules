# Hiera

This module includes a library that enables [Hiera](http://docs.puppetlabs.com/hiera/1/) to be used with Capistrano.

## Installation and Configuration

1. Add the following to your `Capfile`:

```ruby
require_relative 'modules/hiera/lib/cap_hiera'
set :hiera_config 'config/hiera.yaml'
set :hiera_data 'files/hiera'
```

2. Create `config/hiera.yaml`. Please see [this](http://docs.puppetlabs.com/hiera/1/configuring.html) document for a reference.

3. Create a directory `files/hiera`. This is where your data sources will be stored.

## Usage

I recommend create a hierarchy called `capistrano`. Inside this directory, add data sources for each stage that you will use with Capistrano.

A `capistrano/default.yaml` file can be used to contain global settings that apply to all stages.

To obtain values stored in Hiera, use the supplied `hiera` function:

```ruby
destination_directory = hiera('destination_directory')
```

### Server Definition Example

This example supplies global values to launch instances in an OpenStack cloud. The individual staging files can then be used to define servers specific to that stage:

#### capistrano/default.yaml

```yaml
# Global SSH Options
ssh_options:
  :user: 'ubuntu'
  :keys: '/path/to/key'

# Global Server Defaults
server_defaults:
  :cloud: 'mycloud'
  :provider: 'openstack'
  :private_key: '/path/to/key'
  :flavor: 'm1.small'
  :image_id: '4042220e-4f5e-4398-9054-39fbd75a5dd7'
  :keypair: 'home'
  :user: 'ubuntu'
  :security_groups: ['default', 'openstack']
```

#### capistrano/staging.yaml

```yaml
servers:
  'www.example.com':
    :roles:
      - 'www.example.com'
  'db.example.com':
    :roles:
      - 'mysql'
```

#### Capfile

Once servers have been defined in Hiera, add the following to your `Capfile` to have Capistrano read them:

```ruby
hiera_build_servers_from_stage ARGV[0]
```

## Notes

Note that Capistrano's "stages" are completely arbitrary. I think of them more as categories. I could have an "openstack" stage that configures test OpenStack installations, a "workshop" stage that configures virtual machines for a workshop class, or a "galera" stage that configures a Galera cluster of database servers.
