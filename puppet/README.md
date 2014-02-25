# Puppet

This module adds some Puppet tasks including Masterless Puppet support to Capistrano.

The Masterless Puppet workflow is rather opinionated at the moment in that it assumes you are using Hiera with Puppet.

## Requirements

* Hiera module
* Utils module

## Installation and Configuration

Add the following to your `Capfile`:

```ruby
import 'modules/puppet/tasks/puppet.cap'

set :puppet_data, 'files/puppet'
```

## Usage

### Basic

This module contains some basic tasks to install Puppet on remote servers:

```bash
$ cap production puppet:repo:ubuntu
$ cap production puppet:install:ubuntu
# combines both steps
$ cap production puppet::bootstrap:ubuntu
```

### Masterless Puppet

#### Hiera

In order to use Masterless Puppet, first create a directory under your Hiera configuration with the same name as the stage you are deploying. For this example, we will use "production":

```bash
$ mkdir files/hiera/production
```

Inside this directory, create data sources for each server that you will be deploying as well as any global settings in a `default.yaml` file:

* files/hiera/production/default.yaml:

```yaml
packages:
  - 'vim'
  - 'git'
  - 'htop'
```

* files/hiera/production/www.example.com.yaml

```yaml
apache::mpm_module: 'itk'
```

Next, add server entries to Hiera:

* files/hiera/capistrano/production.yaml

```yaml
servers:
  'www.example.com'
    'roles':
      - 'apache'
```

__Note__: At this time, "roles" is only used to categorize servers. You can use Capistrano's "role-filter" to run commands against servers that share a common role. Roles may play a larger role (no pun intended) in the future, so don't write them off quickly.

Finally, create a template that will turn into `hiera.yaml` on the destination server. Most of the time, this template will work:

* files/hiera/tpl/hiera.erb

```yaml
:backends:
  - yaml

:hierarchy:
  - "<%= host %>"
  - "default"

:yaml:
  :datadir: "/etc/puppet/hiera"

:merge_behavior: deeper
```

This template will configure Hiera to look at two locations for data:

  * /etc/puppet/hiera/default.yaml
  * /etc/puppet/hiera/www.example.com.yaml

#### Puppet

Once Hiera has been configured, add two files to `files/puppet/production`:

* files/puppet/production/Puppetfile: This is a standard [Puppetfile](http://librarian-puppet.com/) that will be deployed to each server in the stage.

__Note__: `r10k` is used instead of `librarian-puppet`.

* files/puppet/production/www.example.com.pp: This manifest will be deployed to `www.example.com`. This manifest will contain the configuration for the entire server. If you use the common "Roles & Profiles" Puppet pattern, then this manifest will be a composition of all roles that are applied to the server.

```puppet
include apache
apache::vhost { 'example.com':
  ...
}
```

Settings for this manifest should go in `www.example.com.yaml`.

__Note__: Settings could also go in `default.yaml` but be aware that `default.yaml` is deployed to *all* servers in the stage. This could be an issue if the file contains sensitive information.

#### Puppet Deploy

With these files in place, you will be able to perform the `puppet:deploy` task. This task collects all files described above and transfers them to the remote server(s).

#### Puppet Apply

Once the files have been deployed to the remote server, you can apply them:

```bash
$ cap production puppet:apply[noop]
$ cap production puppet:apply[noop verbose]
$ cap production puppet:apply
$ cap production puppet:apply[verbose]
```

## Credits

Though the task file has changed significantly since I first created it, it was originally based off of [supply_drop](https://github.com/pitluga/supply_drop) and credits are deserved.
