# GKE module

This module create GKE with two secondary subnets for POD network and Service network.
Also create required service accounts and node pool.

TODO
- Add timeout after GKE management plane deployment because it doesn't wait till cluster status is ready (Node pool created after second terragrunt apply).
- Add variable to stict access to management plain, now it's allowed from 0.0.0.0/0
- Enable Application layer secrets encryption (Done)
- After creation of GKE deploy regional-pd storageclass (https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/regional-pd) (done)

