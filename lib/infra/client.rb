class Infra 
  class Client < Thor
    require 'chef'
    require 'chef/config'
    require 'chef/knife'
    require 'timeout'

    include Thor::Actions
   
    class_option :spice,
      :aliases => "-s",
      :type => :string,
      :desc => "The main spiceweasel config file",
      :default => "spice/default.yml"

    class_option :cluster,
      :aliases => "-c",
      :type => :string,
      :desc => "Specify a Spiceweasel cluster file",
      :default => "spice/allinone.yml"

    class_option :spice_opts,
      :aliases => "-o",
      :desc => "Extra options to pass spiceweasel"

    default_task :create 
    desc "create", "Setup various clien layouts"
    def create
      invoke "infra:vagrant"
      invoke "infra:server:create"

      cmd = "bundle exec spiceweasel -e --novalidation "
      cmd << " --cluster-file #{options[:cluster]} " if options[:cluster] 
      cmd << options[:spice_opts] + " " if options[:spice_opts]
      cmd << options[:spice]
      
      run cmd
    end

    desc "clean", "Clean up client environments"
    def clean

      ::Chef::Config.from_file( File.join( destination_root, '.chef', 'knife.rb' ) )

      vagrant_boxes.each do |box|
        chef_client_delete box
        kill_vagrant box
      end
    end

  private

    def chef_client_delete(node)
      puts "cleaning up #{node} on chef server"

      begin
        ::Chef::REST.new(::Chef::Config[:chef_server_url]).delete_rest("clients/#{node}")
        ::Chef::REST.new(::Chef::Config[:chef_server_url]).delete_rest("nodes/#{node}")
      rescue Net::HTTPServerException => e
        if e.message == '404 "Not Found"'
          puts "Server says it doesn't exist continuing.."
        else
          puts "Server reported: #{e.message}\nYou will have to clean the client/node by hand"
        end
      rescue Exception => e
        puts "Caught error while cleaning node from server:\n #{e.message}\nYou will have to clean the client/node by hand"
      end
    end

    def kill_vagrant box
      box_dir = "#{destination_root}/vagrant/#{box}"

      # get the vagrant id so we can clean it up latter
      if File.exist?("#{box_dir}/.vagrant") and File.file?("#{box_dir}/.vagrant")
        vagrant_data = JSON.parse( File.read("#{box_dir}/.vagrant") ) 
      end

      puts "Destroying vagrant box"
      inside box_dir do
        run "vagrant destroy -f", {:verbose => true, :capture => false}
      end

      if vagrant_data
        pids = `ps -ef | grep '#{vagrant_data["active"]["default"]}' | awk '{print $2}'`.split "\n"
        kill_proc pids
      end

      # delete the dir after all that
      FileUtils.rm_rf box_dir
    end

    def kill_proc pids
      return unless pids
      return if pids.empty?
      pids = [ pids ] if pids.is_a? String
      pids.each do |pid|
        puts "trying to kill proccess #{pid}"
        begin
          Process.kill("TERM", pid.to_i)
          Timeout::timeout(30) do
            begin
              sleep 1
            end while !!(`ps -p #{pid}`.match pid)
          end
        rescue Errno::ESRCH
          puts "no process for #{pid} found"
        rescue Timeout::Error
          Process.kill("KILL", pid.to_i)
        end
      end
    end

    def vagrant_boxes
      Dir['vagrant/*'].map { |f| File.basename(f) }
    end

  end
end
