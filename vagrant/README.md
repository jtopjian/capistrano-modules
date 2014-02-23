# Vagrant

This module contains tasks related to Vagrant. It's used in conjunction with the Hiera module.

## Requirements

* Hiera module

## Installation and Configuration

Add the following to your `Capfile`:

```ruby
import 'modules/vagrant/tasks/vagrant.cap'

set :vagrant_data, 'files/vagrant'
```

## Usage

Create a `Vagrantfile` template with the name of `Vagrantfile.cloud.erb` where `cloud` is a server attribute in Hiera. If you read the Hiera module README file, the cloud was called `mycloud`. An example template is included for reference.

Once the template is created, you can launch servers by doing:

```bash
$ cap production vagrant:up
```

This will create Vagrant-based virtual machines of all servers configured in Hiera for the production stage.

## Tricks

Note that individual servers do not need to be configured in Hiera. Rather, you can configure a subdomain of servers and have Vagrant launch a group of them.

For example, the stage "workshop" has the following Hiera configuration:

* files/hiera/capistrano/workshop.yaml

```yaml
servers:
  'workshop.example.com':
    :roles:
      - 'workshop'
```

Next, generate a `Vagrantfile` template like the previous example, but add multiple `define` blocks like this:

```ruby
config.vm.define "vm1.<%= server[:name] %>" do |vm|
end

config.vm.define "vm2.<%= server[:name] %>" do |vm|
end

config.vm.define "vm3.<%= server[:name] %>" do |vm|
end
```

Now when you run `vagrant:up`, Vagrant will create `files/vagrant/workshop/workshop.example.com/Vagrantfile`. That `Vagrantfile` will contain three server definitions. Running `vagrant up` will launch all three of them using the standard Vagrant [multi-machine](http://docs.vagrantup.com/v2/multi-machine/) feature.

The only downside to this "trick" is that you cannot use Capistrano to run tasks on vm1, vm2, or vm3.
