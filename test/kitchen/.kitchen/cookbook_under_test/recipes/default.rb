#
# Cookbook Name:: cloudfoundry-mongodb-service
# Recipe:: default
#
# Copyright 2012, Trotter Cashion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  
cf_id_node = node['cloudfoundry_mongodb_service']['cf_session']['cf_id']

nats_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}   ")
	while nats_nodes.count < 1 
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        nats_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")        
       end
 Chef::Log.warn("Nats server found i am saving it")

nats_node = nats_nodes.first

node.set['cloudfoundry_mongodb_service']['searched_data']['nats_server']['nats_user']= nats_node.nats_server.user
node.set['cloudfoundry_mongodb_service']['searched_data']['nats_server']['nats_password']= nats_node.nats_server.password
node.set['cloudfoundry_mongodb_service']['searched_data']['nats_server']['nats_node']= nats_node.ipaddress
node.set['cloudfoundry_mongodb_service']['searched_data']['nats_server']['nats_port']= nats_node.nats_server.port

cc_nodes = search(:node, "role:cloudfoundry_controller AND cf_id:#{cf_id_node} ")

 	while cc_nodes.count < 1 
        Chef::Log.warn("Waiting for controller .... I am sleeping 7 sec")
        sleep 7
        cc_nodes = search(:node, "role:cloudfoundry_controller AND cf_id:#{cf_id_node}")        
       end
 Chef::Log.warn("Controller found i am saving it")

cc_node = cc_nodes.first

node.set['cloudfoundry_mongodb_service']['searched_data']['cloud_controller']['api_uri'] = cc_node['ipaddress'] # + ":" + cc_node['cloudfoundry_cloud_controller']['server']['external_port'] 
Chef::Log.warn("cc_node.cloudfoundry_cloud_controller.server.api_uri ======================" + cc_node.to_s )

end

#curl_devel = package "libcurl4-openssl-dev" do
#  action :install
#end
#curl_devel.run_action(:install)

#chef_gem "curb"
#chef_gem "do_sqlite3"


include_recipe "cloudfoundry-mongodb-service::gateway"
include_recipe "cloudfoundry-mongodb-service::node"
