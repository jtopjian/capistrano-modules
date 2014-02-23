namespace :ssh do

  desc "Uploads a shared key to the given host"
  task :add_key, [:user, :key] do |t, args|
    if not File.exists?("#{fetch(:ssh_data)}/keys/#{args.key}") or not File.exists?("#{fetch(:ssh_data)}/keys/#{args.key}.pub")
      cap_error "SSH key #{args.key} does not exist"
      exit 1
    end
    on roles(:all) do |s|
      homedir = capture("echo $(eval echo ~#{args.user})")
      if test("[ -d #{homedir} ]")
        sudo "mkdir -p #{homedir}/.ssh"
        upload_and_move "#{fetch(:ssh_data)}/keys/#{args.key}", "#{homedir}/.ssh"
        upload_and_move "#{fetch(:ssh_data)}/keys/#{args.key}.pub", "#{homedir}/.ssh"
        sudo "chown -R #{args.user}: #{homedir}/.ssh"
        sudo "chmod -R 0600 #{homedir}/.ssh"
      else
        cap_error "#{args.user} does not exist on #{s}"
      end
    end
  end

  desc "Adds a host and key to /etc/ssh/ssh_config"
  task :add_host, [:host, :key] do |t, args|
    on roles(:all) do |s|
      if test("sudo ls #{args.key}")
        sudo %Q!echo "Host #{args.host}" | sudo tee -a /etc/ssh/ssh_config!
        sudo %Q!echo "    StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config!
        sudo %Q!echo "    UserKnownHostsFile=/dev/null" | sudo tee -a /etc/ssh/ssh_config!
        sudo %Q!echo "    IdentityFile #{args.key}" | sudo tee -a /etc/ssh/ssh_config!
      else
        cap_error "#{args.key} does not exist on #{s}"
      end
    end
  end

  desc "Runs an arbitrary SSH command and prints the output"
  task :cmd, [:command] do |t, args|
    on roles(:all) do |s|
      puts capture("sudo #{args.command}")
    end
  end

end
