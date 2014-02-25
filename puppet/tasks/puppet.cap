require 'digest/md5'
require 'stringio'
require 'tempfile'
require 'erb'

namespace :puppet do

  namespace :bootstrap do
    desc 'Configures repo and installs Puppet on Ubuntu'
    task :ubuntu do
      invoke 'puppet:repo:ubuntu'
      invoke 'puppet:install:ubuntu'
    end
  end

  namespace :install do
    desc "Installs Puppet via apt on Ubuntu"
    task :ubuntu do
      on roles(:all) do |host|
        sudo 'apt-get update'
        sudo 'apt-get install -y puppet rsync rubygems'
        sudo 'gem install deep_merge'
        sudo 'gem install r10k'
        sudo 'mkdir -p /etc/puppet/hiera'
        sudo 'mkdir -p /etc/facter/facts.d'
        sudo "sed -i 's/\\[main\\]/\\[main\\]\\npluginsync=true/' /etc/puppet/puppet.conf"
        sudo "sed -i 's/\\[main\\]/\\[main\\]\\nparser=future/' /etc/puppet/puppet.conf"
      end
    end
  end

  namespace :repo do
    desc 'Setup the PuppetLabs repo'
    task :ubuntu do
      on roles(:all) do |host|
        sudo 'echo deb http://apt.puppetlabs.com/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/puppet.list'
        sudo 'echo deb http://apt.puppetlabs.com/ $(lsb_release -sc) dependencies | sudo tee -a /etc/apt/sources.list.d/puppet.list'
        sudo 'apt-key adv --keyserver keyserver.ubuntu.com --recv 4BD6EC30'
      end
    end
  end

  namespace :puppetfile do
    desc 'Install modules in the Puppetfile'
    task :install do
      on roles(:all) do |host|
        within '/etc/puppet' do
          sudo 'r10k puppetfile install'
        end
      end
    end
  end

  desc 'Checks the syntax of all *.pp files'
  task :syntax_check do
    cap_info 'Checking syntax...'
    errors = {}
    dir = "#{fetch(:puppet_data)}/#{fetch(:stage)}/"
    Dir.glob("#{dir}/**/*.pp").map do |p|
      output = `puppet parser validate #{p} 2>&1`
      if $?.to_i != 0
        errors[p] = output
      end
      if not errors.empty?
        cap_error 'The following syntax errors were found:'
        errors.each do |file, error|
          cap_error file
          puts error
          puts ""
        end
      end
    end
  end

  desc 'Pushes Puppet files to host'
  task :deploy do

    # set the puppet and hiera directories
    puppet_dir = "#{fetch(:puppet_data)}/#{fetch(:stage)}"

    on roles(:all) do |host|
      cap_info "Deploying Puppet configuration to #{host}"

      # Get a list of files to deploy
      files = build_file_list host

      files.each do |source, destination|
        upload_and_move source, destination
        if source == "#{puppet_dir}/Puppetfile"
          within '/etc/puppet' do
            sudo 'r10k puppetfile install'
          end
        end
      end
    end
  end

  desc 'Runs puppet apply on the server'
  task :apply, [:opts] do |t, args|
    opts = ""
    if args.opts
      args.opts.split(/\s+/).each do |opt|
        opts += "--#{opt} "
      end
    end
    on roles(:all) do |host|
      info "Running puppet apply #{opts} on #{host}"
      puts capture("cd /etc/puppet && sudo puppet apply #{opts} manifests/#{host}.pp")
    end
  end

  private

  def build_file_list host
    files = {}

    stage = fetch(:stage)
    puppet_dir = "#{fetch(:puppet_data)}/#{stage}"
    hiera_dir  = "#{fetch(:hiera_data)}/#{stage}"

    # Render the hiera.yaml file and add it to the file list
    hiera_file = render_hiera host
    if hiera_file
      files.merge!(add_to_file_list(hiera_file, '/etc/puppet/hiera.yaml'))
    end

    # default.yaml
    files.merge!(add_to_file_list("#{hiera_dir}/default.yaml", '/etc/puppet/hiera/default.yaml'))

    # host.pp
    files.merge!(add_to_file_list("#{puppet_dir}/#{host}.pp", "/etc/puppet/manifests/#{host}.pp"))

    # host.yaml
    files.merge!(add_to_file_list("#{hiera_dir}/#{host}.yaml", "/etc/puppet/hiera/#{host}.yaml"))

    # Puppetfile
    files.merge!(add_to_file_list("#{puppet_dir}/Puppetfile", '/etc/puppet/Puppetfile'))

    capture("sudo md5sum #{files.values.join(' ')} 2>/dev/null; echo").split("\n").each do |rfile|
      r_md5sum, r_filename = rfile.split(/\s+/)
      l_filename = files.key(r_filename)
      if Digest::MD5.file(l_filename) == r_md5sum
        files.delete(l_filename)
      end
    end

    files
  end

  def render_hiera host
    stage = fetch(:stage)

    # Determine the hiera file to use
    hiera_tpl = nil
    if File.exists?("#{fetch(:hiera_data)}/tpl/hiera.#{stage}.erb")
      hiera_tpl = "#{fetch(:hiera_data)}/tpl/hiera.#{stage}.erb"
    elsif File.exists?("#{fetch(:hiera_data)}/tpl/hiera.erb")
      hiera_tpl = "#{fetch(:hiera_data)}/tpl/hiera.erb"
    end

    if hiera_tpl
      h = Tempfile.new('cap')
      h.puts ERB.new(File.new(hiera_tpl).read).result(binding)
      h.close
    end
    return h.path

  end


  def add_to_file_list source, destination
    x = {}
    if File.exists?(source)
      x[source] = destination
    end
    return x
  end

  def puppet_apply opts
    on roles(:all) do |host|
      info "Running puppet apply #{opts} on #{host}"
      puts capture("cd /etc/puppet && sudo puppet apply #{opts} manifests/#{host}.pp")
    end
  end

end
