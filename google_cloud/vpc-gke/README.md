#VPC GKE module

This module create vpc with two secondary subnets for GKE POD network and Service network.
Also creates vpc router, Nat gateway, and default FW rule to allow network from targets with tag private.

TODO
- Add dependancies and timeout after VPC creation


