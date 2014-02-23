namespace :utils do

  desc "Check the uptime of servers"
  task :uptime do
    on roles(:all) do |host|
      info "Host #{host}: #{capture(:uptime)}"
    end
  end

end
