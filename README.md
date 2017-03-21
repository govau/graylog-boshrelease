# graylog-boshrelease
BOSH release for graylog (https://www.graylog.org/) - tool for centrally collecting logging events for your infrastructure and applications.

NOTE: this is initial development release and is not recommended for production environments.  it has currently only been tested with BOSH-lite.

### Creating a development bosh release
```
bosh create release --force
bosh upload release
```

### Deploying to *bosh-lite*.
a sample cloud-config and deployment manifest is provided in the `templates` directory.

```
bosh update cloud-config templates/bosh-lite-cloud-config.yml
bosh deployment templates/bosh-lite-deployment.yml
bosh deploy
```


### attribution
This BOSH release for Graylog was heavily inspired by an existing BOSH release for the ELK stack - https://github.com/cloudfoundry-community/logsearch-boshrelease.  
A large amount of the code for the _elasticsearch_ jobs and packages has been copied from the ELK BOSH release and re-used here.


### TODO
- add authentication to mongodb
- add better management of multiple graylog instances
