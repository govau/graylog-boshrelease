# graylog-boshrelease

BOSH release for graylog (<https://www.graylog.org/>) - tool for centrally collecting logging events for your infrastructure and applications.

## Usage

### Setting up local environment

1. Assumes Bosh2 is installed with binary named `bosh`.

1. Setup a local BOSH2 environment with VBOX: <https://github.com/cloudfoundry/bosh-deployment>. Tip: use `export BOSH_ENVIRONMENT=vbox` to avoid needing to pass `-e vbox` to all subsequent `bosh` commands.

1. Remember to apply the provided BOSH cloud-config: <https://github.com/cloudfoundry/bosh-deployment/blob/master/warden/cloud-config.yml>

    ```bash
    bosh update-cloud-config ./warden/cloud-config.yml
    ```

1. fetch a stemcell from bosh.io

    ```bash
    bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
    ```

### Deploying Default graylog deployment

The base manifest `manifests/graylog.yml` should "Just Work".
It is setup with with BOSH linking so no static-ip addresses or specific settings should be required.  It uses `default` for vm_type, stemcell, persistent_disk_type, and networks as setup in the cloud-config above.

```bash
bosh deploy -n -d graylog manifests/graylog.yml
```

Check the running VMs:

```bash
bosh vms
```

Returns:

```text
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

Point your browser the IP address for the graylog instance on port 9000 (above example would be <http://10.244.0.6:9000>).
You should be prompted with the graylog login page.  The default credentials provided in the `manifests/graylog.yml` are admin/admin.

### Using Operator files

BOSH2 operator files allow you to extend/replace parts of the default deployment manifest.  4 operator files are provided

#### network customisation - `manifests/operators/network.yml`

This operator allows you to deploy to a cloud-config network that isn't `default`.  It also allows you set a static ip address for the graylog instance.
eg.

```bash
bosh deploy -n -d graylog manifests/graylog.yml \
    -o manifests/operators/network.yml \
    -v network-name=logging \
    -v graylog-static-ip=10.244.0.34
```

#### graylog root account  - `manifests/operators/graylog-accounts.yml`

set custom root username/email/password (you *will* want to do this!!)

```bash
bosh deploy -n -d graylog manifests/graylog.yml \
    -o manifests/operators/graylog-accounts.yml \
    -v password_secret=reallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallybigsecret \
    -v graylog-root-email=operations@example.com \
    -v graylog-root-username=administrator \
    -v graylog-root-password-sha2=c7a751ec361695f6ebf546d503657dc0fd86bed2bac136a7352d2b4be1b55604
```

note: generate a sha2 hash of a password by running `echo my-big-secret | shasum -a 256`

For bonus points, you could stick sensitive variables (secrets) into credhub.  The benefit is now you don't require them when running the `bosh deploy` command.

```bash
credhub set -n "/Bosh Lite Director/graylog/password-secret" -v "bigsecret"
credhub set -n "/Bosh Lite Director/graylog/graylog-root-email" -v "operations@example.com"
credhub set -n "/Bosh Lite Director/graylog/graylog-root-username" -v "administrator"
credhub set -n "/Bosh Lite Director/graylog/graylog-root-password-sha2" -v "c7a751ec361695f6ebf546d503657dc0fd86bed2bac136a7352d2b4be1b55604"
bosh deploy -n -d graylog manifests/graylog.yml \
    -o manifests/operators/graylog-accounts.yml
```

#### Graylog Web Endpoint URL  - `manifests/operators/web-endpoint-uri.yml`

This operator allows you to set the `web_listen_uri` configuration value.  This is the external address of the REST API of the Graylog server. Web interface clients need to be able to connect to this for the web interface to work. see [url](http://docs.graylog.org/en/2.2/pages/configuration/web_interface.html)

```bash
bosh deploy -n -d graylog manifests/graylog.yml \
    -o manifests/operators/web-endpoint-uri.yml \
    -v graylog-web-uri="https://logging.example.com"
```

#### Graylog listen port  - `manifests/operators/listen-port.yml`

By default graylog listens on port `9000`.  This operator allows you to make it listen on a different port.

```bash
bosh -n -d graylog manifests/graylog.yml \
    -o manifests/operators/listen-port.yml \
    -v graylog-listen-port=8000
```

## Local Development

You can make changes and create local dev releases.
Create a local BOSH dev release for graylog

```bash
bosh create-release --force --name graylog
bosh upload-release
bosh deploy -n -d graylog manifests/graylog.yml
```

### Attribution

This BOSH release for Graylog was heavily inspired by an existing BOSH release for the ELK stack - <https://github.com/cloudfoundry-community/logsearch-boshrelease>.
A large amount of the code for the _elasticsearch_ jobs and packages has been copied from the ELK BOSH release and re-used here.

### TODO

- add authentication to mongodb
- add better management of multiple graylog instances
- set the `node_id_file` to be the deployment instance name and index of deployment rather than random string
