# graylog-boshrelease
BOSH release for graylog (https://www.graylog.org/) - tool for centrally collecting logging events for your infrastructure and applications.

## Usage

### Developing and deploying locally
Setup a local BOSH2 environment with VBOX.  Follow https://github.com/cloudfoundry/bosh-deployment
Remember to apply the provided BOSH cloud-config https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml


Create a local BOSH dev release for graylog
```
bosh2 create-release --force --name graylog
bosh2 -e vbox upload-release
```

The base manifest `manifests/graylog.yml` should "Just Work".  It is setup with with BOSH linking so no static-ip addresses or specific settings should be required.  It uses `default` for vm_type, stemcll, persistent_disk_type, and networks as setup in the cloud-config above.
```
bosh2 -e vbox deploy -n -d graylog manifests/graylog.yml
```

Check the running VMs
```
$ bosh2 vms
Using environment '192.168.50.6' as client 'admin'

Task 56. Done

Deployment 'graylog'

Instance                                                   Process State  AZ  IPs         VM CID                                VM Type
elasticsearch-data/2ad178ba-612c-4282-b22c-81915deb3fdd    running        z1  10.244.0.5  bd23c68f-737f-4e34-551a-100d0ebec3bd  default
elasticsearch-data/763aadcb-b866-4b73-a13f-05fe7db2b79a    running        z1  10.244.0.4  11f16ae0-e8dd-48a3-7ad3-09dfa0ced59b  default
elasticsearch-master/0a659b3d-3156-4919-b255-c618177c34c7  running        z1  10.244.0.3  961ca2a8-8c95-4b82-4519-8d94c39de345  default
graylog/f812bbca-3057-4236-b2c8-6ba007fa7f9d               running        z1  10.244.0.6  92b31138-b4e6-4395-6e25-fb57cc4fbcf7  default
mongodb/e5a742e9-4f59-45bb-b957-bab36cae4aa5               running        z1  10.244.0.2  7d4ae78b-8c67-4c86-7c2d-0c41bd7709fd  default

5 vms

Succeeded
```

Point your browser the IP address for the graylog instance on port 9000 (above it is 10.244.0.6).
You should be prompted with the graylog login page.  The default credentials provided in the `manifests/graylog.yml` are admin/admin.



### attribution
This BOSH release for Graylog was heavily inspired by an existing BOSH release for the ELK stack - https://github.com/cloudfoundry-community/logsearch-boshrelease.  
A large amount of the code for the _elasticsearch_ jobs and packages has been copied from the ELK BOSH release and re-used here.


### TODO
- add authentication to mongodb
- add better management of multiple graylog instances
