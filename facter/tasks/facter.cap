namespace :facter do

  namespace :install do
    desc "Installs Facter via apt"
    task :ubuntu do
      on roles(:all) do |host|
        sudo "apt-get update"
        sudo "apt-get install -y facter"
        sudo "mkdir -p /etc/facter/facts.d"
      end
    end
  end

  namespace :fact do
    desc "Adds a fact via facter-dot-d on a remote host"
    task :add, [:fact,:value] do |t, args|
      on roles(:all) do |host|
        execute "echo #{args.fact}=#{args.value} | sudo tee /etc/facter/facts.d/#{args.fact}.txt"
      end
    end

    desc "Retrieves a specific fact from a remote host"
    task :get, [:fact] do |t, args|
      on roles(:all) do |host|
        info "Retrieving fact #{args.fact} from #{host}"
        puts capture("sudo facter #{args.fact}")
      end
    end

    desc "Retreives all facts from a remote host"
    task :all do
      on roles(:all) do |host|
        info "Retrieving all facts from #{host}"
        puts capture("sudo facter")
      end
    end
  end
end
