# Vagrant Tasks
namespace :vagrant do

  # Given a server name, this task will create a directory and
  # Vagrantfile for that server.
  #
  # It requires that a server is defined in hiera first.
  desc "Create a new Vagrant instance"
  task :new do
    roles(:all).each do |s|
      server = hiera_get_server s
      # Check to see if an instance already exists
      # Render a Vagrantfile template if it doesn't
      dir = "#{fetch(:vagrant_data)}/#{server[:cloud]}/#{server[:name]}"
      if File.exists?("#{dir}/Vagrantfile")
        cap_warn "#{server[:name]} already created. Moving on."
      else
        cap_info "Building #{dir}/Vagrantfile"
        sh "mkdir -p #{dir}"
        template = "#{fetch(:vagrant_data)}/tpl/Vagrantfile.#{server[:cloud]}.erb"
        render_template(template, "#{dir}/Vagrantfile", binding)
      end
    end
  end

  # Given a server name, this task will run vagrant:new and then
  # boot the server
  desc "Create and launch a new Vagrant instance"
  task :up do
    roles(:all).each do |s|
      server = hiera_get_server s
      # run vagrant:new to create the machine
      invoke 'vagrant:new'

      dir = "#{fetch(:vagrant_data)}/#{server[:cloud]}/#{s}"

      # Check and see if the server has a specific vagrant provider
      if server.key?(:provider)
        provider = "--provider=#{server[:provider]}"
      else
        provider = ""
      end

      sh <<-EOS
        cd #{dir}
        vagrant up #{provider}
      EOS
    end
  end

  # Destroy and cleanup a vagrant server
  desc "Destroy and cleanup a vagrant server"
  task :destroy do
    roles(:all).each do |host|
      server = hiera_get_server host
      dir = "#{fetch(:vagrant_data)}/#{server[:cloud]}/#{host}"
      sh <<-EOS
        cd #{dir}
        vagrant destroy
        if [ $? -eq 0 ]; then cd ..; rm -rf #{host}; fi
      EOS
    end
  end

end
