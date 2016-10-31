# Build the ZCOST CloudStack for production

# High level architecture

<img src="https://raw.githubusercontent.com/zcost/orchestra-books/master/cloudstack/architecture.png">

# Deployment Architecture
We are going to deploy Baremetal.

<img src="https://raw.githubusercontent.com/zcost/orchestra-books/master/cloudstack/deployment.png">

# Workflow Process

The deployment of docker swarm cluster has following process.

<img src="https://raw.githubusercontent.com/zcost/orchestra-books/master/cloudstack/workflow.png">

Task Name | Task URI
----        | ----
Register Infrastructure | https://github.com/zcost/orchestra-books/blob/master/cloudstack/register-infra.md
Register Baremetals     | https://github.com/zcost/orchestra-books/blob/master/cloudstack/register-baremetal.md
Install CloudStack Management | https://github.com/zcost/orchestra-books/blob/master/cloudstack/cloudstack-management2.md
Update Cnode Network    | https://github.com/zcost/orchestra-books/blob/master/cloudstack/cnode-network.md
Install CloudStack Agent | https://github.com/zcost/orchestra-books/blob/master/cloudstack/cloudstack-agent.md


# Default Environment

Keyword | Value | Description
----    | ----  | ----
KEY_NAME   | server    | Keypair name
REGION_NAME | ap-northeast-2    | Region name for Provisioning
ZONE_NAME   | zcost-1   | Zone name for servers
CS_PASSWORD     | password          | MySQL password for cloud account
VER             | 4.8               | CloudStack Version
USER_ID     | admin     | user_id for this system
PASSWORD    | password  | password for this system

# Reference
