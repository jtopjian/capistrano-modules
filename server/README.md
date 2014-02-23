# Server

This module contains generic tasks that can be applied to all types of servers -- both bare metal and virtual.

## Installation and Configuration

Add the following to your `Capfile`:

```ruby
import 'modules/server/tasks/server.cap'

set :server_data, 'files/server'
```

## Usage

### List Servers

The `servers:list` task is a simple task that will list all servers configured for the given stage. This is helpful if you have configured Hiera with Capistrano:

```bash
$ cap production servers:list
www.example.com
db.example.com
```

### Bootstrap Servers

This task will upload and run a shell script located at `files/servers/bootstraps`. This is useful to run some initial basic commands when a server is first created.

```bash
$ echo "apt-get update" > files/server/bootstraps/ubuntu.sh
$ cap production server:bootstrap[ubuntu.sh]
```

__Note__: `bootstrap` is an arbitrary name. There is nothing preventing you from using this task at a later phase of the server lifecycle.
