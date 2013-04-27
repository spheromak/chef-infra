#
# Thorfile for infra
#
$:.push File.expand_path("../lib", __FILE__)

require 'bundler'
require 'bundler/setup'

class Infra <  Thor
  require 'infra/server'
  require 'infra/client'

  include Thor::Actions

  class_option :spice,
    :aliases => "-s",
    :type => :string,
    :desc => "The main spiceweasel config file",
    :default => "spice/ng_ostack.yml"

  class_option :cluster,
    :aliases => "-c",
    :type => :string,
    :desc => "The main spiceweasel config file",
    :default => "spice/ng_ostack.yml"

  class_option :spice_opts,
    :aliases => "-o",
    :desc => "Extra options to pass spiceweasel"

  def self.source_root
    File.dirname(__FILE__)
  end

  desc "all", "Build the server then clients as specified by the spice config"
  def all
    invoke :vagrant
    invoke "infra:server:create"
    invoke "infra:client:create" 
  end

  desc "clean", "Clean up all the things"
  def clean
    invoke "infra:client:clean"
    invoke "infra:server:clean"
  end

  desc "vagrant", "install vagrant plugins"
  def vagrant
    # TODO: Terrible using system here, need to look @ thor more to
    # see what we can do to make this sane, or possibly use mxin::command?
    plugins = `vagrant plugin list`.split("\n").map { |i| i.split(" ")[0] }
    %w/vagrant-berkshelf vagrant-chefnode vagrant-omnibus/.each do |plugin|
      run "vagrant plugin install #{plugin}" unless plugins.include? plugin
    end
  end


  default_task :all
end
