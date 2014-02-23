# SSH

This module contains tasks related to SSH.

## Requirements

* Utils module

## Installation and Configuration

Add the following to your `Capfile`:

```ruby
import 'modules/ssh/tasks/ssh.cap'

set :ssh_data, 'files/ssh'
```

## Usage

### Uploading SSH Keys

To upload a SSH key to a remote servers, add the public and private key to `files/ssh/keys` and then run:

```bash
$ ls files/ssh/keys
mykey mykey.pub
$ cap production ssh:add_key[root,mykey]
```

The key will then be uploaded to `/root/.ssh` on the remote server(s).

### Adding Host Entries

To add a host entry that corresponds to an uploaded key, run the following:

```bash
$ cap production ssh:add_host[example.com,/root/.ssh/mykey]
```

The remote server will then be able to contact `example.com` using `mykey`.

### Executing Ad-Hoc Commands

You can use this module to run ad-hoc commands via SSH:

```bash
$ cap production ssh:cmd['ls -l']
```
