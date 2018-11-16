

# Ansible / OpenNebula VM setup playbooks

## Intent

* Factory-Resetting of a base image for re-use (deleting keys etc)
* Applying updates on all platforms (for refreshing base images)
* Config of instantiated deploy images
* Applying baseline settings to secure base images (i.e. a Rudder Policy run to have all security settings)


## Prereqs

* ansible-one-inv (https://github.com/FELDSAM-INC/ansible-one-inv) for listing running VMs
* npm for the above
* Alle VMs des ONE service template sind mit einem LABEL versehen (hier: "ci")
* All VM templates contained in the ONE service template should have a shared LABEL ("ci") which ansible-one-inv uses to filter

## Behaviour

Proxy is only configured while applying patches / installing software, but not added to the package manager config.
This allows to later configure it differently (i.e. if the base images are refreshed on a trusted net, but not 
the VM instances created from those)
The rudder master is configured using group_vars, allowing to set it differently for different LABELs in ONE.


## Caveat

The playbooks _can_ be used in a cycle, i.e. update, run rudder, wipe all config.
Not always this is what you want, for that reason the playbooks support 
additional tags named "setup" and "wipe", allowing partial runs.
Unfortunately in first tests this didn't work super reliable.

## Setup

* configure ansible-one-inv: use config.sample.js to create and adjust config.js
* check if https works for you :-)
* check that you're using a user with access permissions to network / templates / images

call:

```/usr/local/bin/ansible-playbook -i ./one-inv ../ansible-onesvc/setup.yml```

listing steps:

```
$ /usr/local/bin/ansible-playbook -i ./one-inv ../ansible-onesvc/setup.yml --list-tasks

playbook: ../ansible-onesvc/setup.yml

  play #1 (ci): ci	TAGS: []
    tasks:
      updates : Update and upgrade apt packages	TAGS: []
      updates : Install test package	TAGS: []
      updates : Update and upgrade rpm packages	TAGS: []
      updates : Install selinux bindings	TAGS: []
      updates : Install test package	TAGS: []
      updates : Update and upgrade rpm packages	TAGS: []
      updates : Install libssl	TAGS: []
      updates : Install test package	TAGS: []
      updates : Update and upgrade apk packages	TAGS: []
      updates : Install test package	TAGS: []
      updates : Update pkg	TAGS: []
      updates : Upgrade pkg	TAGS: []
      updates : Update and upgrade pkg packagesj	TAGS: []
      updates : Install test package	TAGS: []
      rudder : rudder agent repo key	TAGS: []
      rudder : rudder repo	TAGS: []
      rudder : rudder agent install	TAGS: []
      rudder : rudder repo key	TAGS: []
      rudder : rudder agent repo	TAGS: []
      rudder : rudder agent install	TAGS: []
      rudder : rudder agent repo	TAGS: []
      rudder : rudder agent install	TAGS: []
      rudder : Rudder master config	TAGS: [setup]
      rudder : Rudder agent reinit	TAGS: [setup]
      rudder : Rudder agent enable	TAGS: [setup]
      rudder : Rudder agent inventory	TAGS: [setup]
```

As you can see, some steps are missing tags, they are only important for steps which
* configure something
* delete config/keys/logs

