# graylog-boshrelease
BOSH release for graylog (https://www.graylog.org/) - tool for centrally collecting logging events for your infrastructure and applications.

NOTE: this is initial development release and is not recommended for production environments.  it has currently only been tested with BOSH-lite.

### Creating a development bosh release
```
bosh create release --force
bosh upload release
```

### Deploying to *bosh-lite*.
A sample cloud-config and deployment manifest is provided in the `templates` directory.  
There is a bunch of settings available to be tuned in the deployment manifest. In each of the jobs there is a spec file that contains a properties key. Any of these can be add to the `properties:` at the bottom of your deployment manifest.

```
cp templates/bosh-lite-deployment.yml bosh-lite-deployment.yml
bosh update cloud-config templates/bosh-lite-cloud-config.yml
bosh deployment bosh-lite-deployment.yml
bosh deploy
```


### attribution
This BOSH release for Graylog was heavily inspired by an existing BOSH release for the ELK stack - https://github.com/cloudfoundry-community/logsearch-boshrelease.  
A large amount of the code for the _elasticsearch_ jobs and packages has been copied from the ELK BOSH release and re-used here.


### TODO
- add authentication to mongodb
- add better management of multiple graylog instances
