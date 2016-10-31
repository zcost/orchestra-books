# Create Region

# Environment

Keyword | Value | Description
----    | ----  | ----
URL     | http://127.0.0.1/api/v1 | URL for request
TOKEN   | my_token              | Token for API (must be overrided)
METADATA      | http://127.0.0.1/api/v1/catalog/{stack_id}/env | Environment URL for stack
USER_ID | admin  | user_id of Orchestra account
PASSWORD| password | password of Orchestra account
ZONE_NAME| zcost-1  | Zone name for servers
REGION_NAME  | ap-northeast-2    | Region name for Provisioning
STACK_ID    | xxxx              | StackID is automatically overrided by system

# Region/Zone

Add Baremetal Server information

~~~python
import requests
import json
import pprint,sys,re

class writer:
    def write(self, text):
        text=re.sub(r'u\'([^\']*)\'', r'\1',text)
        sys.stdout.write(text)

wrt=writer()

pp = pprint.PrettyPrinter(indent=2, stream=wrt)

def show(dic):
    print pp.pprint(dic)

def display(title):
    print "\n"
    print "################# " + '{:20s}'.format(title) + "##############"

header = {'Content-Type':'application/json'}

def makePost(url, header, body):
    r = requests.post(url, headers=header, data=json.dumps(body))
    if r.status_code == 200:
        return json.loads(r.text)
    print r.text
    raise NameError(url)

def makePut(url, header, body):
    r = requests.put(url, headers=header, data=json.dumps(body))
    if r.status_code == 200:
        return json.loads(r.text)
    print r.text
    raise NameError(url)


def makeGet(url, header):
    r = requests.get(url, headers=header)
    if r.status_code == 200:
        return json.loads(r.text)
    print r.text
    raise NameError(url)

def makeDelete(url, header):
    r = requests.delete(url, headers=header)
    if r.status_code == 200:
        return json.loads(r.text)
    print r.text
    raise NameError(url)

def addEnv(url, body):
    r = requests.post(url, headers=hdr, data=json.dumps(body))
    if r.status_code == 200:
        result = json.loads(r.text)

display('Auth')
url = '${URL}/token/get'
user_id='${USER_ID}'
password='${PASSWORD}'
body = {'user_id':user_id, 'password':password}
token = makePost(url, header, body)
token_id = token['token']
header.update({'X-Auth-Token':token_id})

display('List Regions')
url = '${URL}/provisioning/regions?name=${REGION_NAME}'
region1 = makeGet(url, header)
show(region1)
region_id = region1['results'][0]['region_id']
print "Region ID: ", region_id

display('List Zones')
url = '${URL}/provisioning/zones?name=${ZONE_NAME}' 
zone1 = makeGet(url, header)
show(zone1)
zone_id = zone1['results'][0]['zone_id']
print "Zone ID: ", zone_id

cnodes = []
for i in range(5):
    s_url = '${URL}/provisioning/servers'
    name = "cnode%.2d-R01" % (i+1)
    ip = "10.1.1.%d" % (i + 1)
    key_name = "server"
    req = {'private_ip_address':ip}
    body = {'name':name, 'zone_id':zone_id, 'key_name':key_name, 'request':req}
    server = makePost(s_url, header, body)
    cnodes.append(server['server_id'])
    show(server)

# Add metadata to stack(@cnodes)
body = {'add':{'cnodes':cnodes}}
addEnv('${METADATA}',body)

display('Add CloudStack VM to managemnet zone')
url = '${URL}/provisioning/zones?name=management'
zone2 = makeGet(url, header)
show(zone2)
zone_id = zone2['results'][0]['zone_id']
print "Zone ID: ", zone_id
s_url = '${URL}/provisioning/servers'
name = "cloudstack01-vm"
ip = "10.2.0.11"
key_name = "server"
req = {'private_ip_address':ip}
body = {'name':name, 'zone_id':zone_id, 'key_name':key_name, 'request':req}
server = makePost(s_url, header, body)
show(server)
mgmt = []
mgmt.append(server['server_id'])
body = {'add':{'mgmt':mgmt}}
addEnv('${METADATA}',body)

~~~
