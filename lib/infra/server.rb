class Infra 
  class Server < Thor
    include Thor::Actions

    default_task :create
    desc  "create", "Create the server"
    def create
      invoke "infra:vagrant"
      run "vagrant up"
      unless File.exist?(".chef/vagrant.pem") 
        run "knife server bootstrap standalone  --node-name 172.30.10.10 --ssh-user vagrant  --ssh-password vagrant --host 172.30.10.10 --prerelease --sudo"
      end
    end
   
    desc "clean", "Clean up the server"
    def clean
      run "vagrant destroy -f", {:verbose => false, :capture => false}
      run "rm -vf .chef/*.pem" 
    end

  end
end
