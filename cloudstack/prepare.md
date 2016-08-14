
# Environment

Keyword | Value | Description
----    | ----  | ----
URL     | http://127.0.0.1/api/v1 | URL for request
TOKEN   | my_token              | Token for API (must be overrided)
METADATA      | http://127.0.0.1/api/v1/catalog/{stack_id}/env | Environment URL for stack
ZONE | seoul  | Zone name

# Prepare Server information

We needs to define @mnode, @cloudstack01-vm, @RACK01

~~~python
import requests
import json
import time

hdr = {'Content-Type':'application/json','X-Auth-Token':'${TOKEN}'}
def getZoneID(name):
    url = '${URL}/provisioning/zones?name=%s' % name
    try:
        r =requests.get(url, headers=hdr)
        print r.text
        if (r.status_code == 200):
            result = json.loads(r.text)
            print result
            return result['results'][0]['zone_id']
    except requests.exception.ConnectionError:
        print "Failed to connect"


def listServers(zone_id):
    url = '${URL}/provisioning/servers?zone_id=%s' % zone_id
    try:
        r =requests.get(url, headers=hdr)
        if (r.status_code == 200):
            result = json.loads(r.text)
            rack = []
            for server in result['results']:
                rack.append(server['server_id'])
            return rack
    except requests.exception.ConnectionError:
        print "Failed to connect"

def getServer(name):
    url = '${URL}/provisioning/servers?name=%s' % name
    try:
        r =requests.get(url, headers=hdr)
        if (r.status_code == 200):
            result = json.loads(r.text)
            rack = []
            return result['results'][0]['server_id']
    except requests.exception.ConnectionError:
        print "Failed to connect"


def addEnv(url, body):
    r = requests.post(url, headers=hdr, data=json.dumps(body))
    if r.status_code == 200:
        result = json.loads(r.text)

# Node group
zone_id = getZoneID('${ZONE}')
rack = listServers(zone_id)

# Add environment of RACK01
body = {'add':{'RACK01':rack}}
addEnv('${METADATA}', body)

# Get cloudstack01-vm
s_id = getServer('cloudstack01-vm')
body = {'add':{'jeju':{'cloudstack01-vm':[s_id]}}}
addEnv('${METADATA}', body)

# Get mnode
s_id = getServer('mnode')
body = {'add':{'jeju':{'mnode':[s_id]}}}
addEnv('${METADATA}', body)


~~~
