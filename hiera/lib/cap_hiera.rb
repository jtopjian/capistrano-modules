require 'hiera'

module CapHiera

  def hiera key, options = {}

    scope = {}

    if options.key?(:host)
      scope['host'] = options[:host]
      scope['role'] = options[:host].roles.to_a
    end

    if options.key?(:stage)
      scope['stage'] = options[:stage]
    else
      scope['stage'] = fetch(:stage)
    end

    begin
      @@h ||= Hiera.new({:config => fetch(:hiera_config)})
    rescue Exception => e
      STDERR.puts "Failed to start Hiera: #{e.class}: #{e}"
      exit 1
    end
    @@h.lookup(key, 'nil', scope, order_override=nil, resolution_type=:priority)
  end

  def hiera_build_servers_from_stage stage
    if stage
      servers = hiera('servers', {:stage => stage})
      if servers
        servers.each do |k,v|
          server k, v
        end
      end
    end
  end

  def hiera_get_server host
    host = host.to_s
    servers = hiera('servers')
    if not servers.key?(host)
      return nil
    else
      server_defaults = hiera('server_defaults')
      if server_defaults.is_a?(Hash)
        server = server_defaults.merge(servers[host])
      else
        server = servers[host]
      end
      server[:name] = host
      return server
    end
  end

end

include CapHiera
