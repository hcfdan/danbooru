set :user, "danbooru"
set :rails_env, "production"
server "sonohara.donmai.us", :roles => %w(web app db), :primary => true, :user => "danbooru"

