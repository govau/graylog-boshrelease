# Usage
Use operations files to run over the base bosh-lite-deployment.yml manifest.
Operations files allow you to overwrite or insert settings over an existing manifest.

# Requirements
- BOSH CLIv2 (https://bosh.io/docs/cli-v2.html)
- If deploying into AWS, a bosh director that can talk to AWS.

# Includes
### virtualbox
- vbox-cloud-config.yml
  - An example config to get started with virtualbox
- ops-vbox.yml
  - An example operations file to get started with virtualbox cloud config example
### aws
- aws-cloud-config.yml
  - Fix up the # FIX ME sections with what is in your infrastructure
  - An example aws cloud config file, you will need to make sure that some items are created in aws (feel free to change the cidr blocks with whatever you want to use, but remember to change up the ops file/cloud config if you change things):
    - VPC with 4 subnets in avalability zone a
      - compilation_a: 10.148.0.0/24
      - mongodb_a: 10.148.1.0/24
      - elasticsearch_a: 10.148.2.0/24
      - graylog_a: 10.148.3.0/24
    - Any security groups to allow them to communicate
    - A way to access the environment (VPN of some sort as graylog and elasticIP is a bit fiddly)
- ops-aws.yml
  - An example operations file to get you started with the aws cloud config example

# Virtualbox Example
Create a directory and run the steps as follows inside that directory, this will create a bosh director in virtualbox and spin up the graylog deployment
```
mkdir /path/to/test/dir
cd /path/to/test/dir

git clone https://github.com/cloudfoundry/bosh-deployment.git

bosh create-env bosh-deployment/bosh.yml --state vbox/state.json -o bosh-deployment/virtualbox/cpi.yml -o bosh-deployment/virtualbox/outbound-network.yml -o bosh-deployment/bosh-lite.yml -o bosh-deployment/bosh-lite-runc.yml -o bosh-deployment/jumpbox-user.yml --vars-store vbox/creds.yml -v director_name="Bosh Lite Director" -v internal_ip=192.168.50.6 -v internal_gw=192.168.50.1 -v internal_cidr=192.168.50.0/24 -v outbound_network_name=NatNetwork
```
Check that it works
```
bosh -e 192.168.50.6 alias-env vbox --ca-cert <(bosh int vbox/creds.yml --path /director_ssl/ca)
```
Get the password
```
bosh int vbox/creds.yml --path /admin_password
```
Log in with admin and the password
```
bosh -e vbox login
```
Make sure you can route to what you build on the director
```
sudo route add -net 10.244.0.0/16 gw 192.168.50.6
```
Clone the graylog repo
```
git clone <repo>/graylog-boshrelease
cd graylog-boshrelease
```
Upload the example vbox-cloud-config.yml file
```
bosh -e vbox ucc examples/vbox-cloud-config.yml
```
Upload the stemcell if you haven't got it already
```
bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
```
Create and upload the release
```
bosh create-release --force
bosh upload-release
```
Run the deployment using the base template, using an operations file to overwrite default values
The ops-vbox.yml file contains operations to make it work in the example vbox-cloud-config run earlier
```
bosh -e vbox -d graylog deploy templates/bosh-lite-deployment -o examples/ops-vbox.yml
```
Once its done, you should be able to navigate to http://10.244.1.25:9000 in your browser and log in with admin/admin (it can take a bit of time for graylog to start, be patient)

# AWS Example
I won't go into the details of creating an AWS director here, but deploying is basically the same as for virtualbox, upload your AWS cloud config to your AWS director, then run the deployment
```
bosh -e aws-director ucc examples/aws-cloud-config.yml
bosh -e aws-director -d graylog deploy templates/bosh-lite-deployment -o examples/ops-aws.yml
```
