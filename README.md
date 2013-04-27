# Chef Infra

This is how i manage spinning up multi-node infra projects for testing. 

Some people at chef conf were interested in how I test infrastructures.thats what this is.

# Why

This is meant to bea set of thor tasks, spice files and vagrant file to bootstrap an arbitrary "infrastructure"

I use this to help developers get setup with openstack clusters, and on our CI environment to setup a functional testing invironment. 

# Requirements

You have to have vagrant 1.1+ installed (omni vagrant) This is inteneded to work with that The gem file should get it

# Using It

from the project root: 

     bundle install

drop these files into your chef project repo.  If you are using Berkshelf it will work as-is. If you are not then you will have to edit spice/default.yml to include the cooks you want.

     bundle exec thor llist


### Set up default

     bundle exec thor infra 


### Use a non default spice "cluster" 
edit the spice/cluster files to your liking or add your own

     bundle exec thor infra -c spice/cluster_2node.yml
     




