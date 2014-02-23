namespace :server do

  # Given a server name and bootstrap script,
  # copy the bootstrap script to the server and
  # run it
  desc "Bootstrap a server with a given script"
  task :bootstrap, [:script] do |t, args|

    # Check if the bootstrap file exists
    if not File.exists?("#{fetch(:server_data)}/bootstraps/#{args.script}")
      cap_error "#{args.script} does not exist."
      exit 1
    end

    # Upload the script to the server and run it
    on roles(:all) do |host|
      upload! "#{fetch(:server_data)}/bootstraps/#{args.script}", './'
      sudo "bash #{args.script}"
    end
  end

  # List known servers after all filters have been applied
  desc "List known servers"
  task :list do
    roles(:all).each do |s|
      puts s
    end
  end

end
