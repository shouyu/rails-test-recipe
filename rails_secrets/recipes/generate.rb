include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][:application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end


  deploy = node[:deploy][:application]

  template "#{app_root}/config/secrets.yml" do
    source "secrets.yml.erb"
    cookbook "rails_secrets"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(
      :secret => deploy[:secret],
      :environment => deploy[:rails_env]
    )
    log "rails_secrets"
    log "deploy[:secret].present?: #{deploy[:secret].present?"
    log "File.directory?(#{deploy[:deploy_to]}/shared/config/): #{File.directory?(\"#{deploy[:deploy_to]}/shared/config/\")}"

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      deploy[:secret].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
