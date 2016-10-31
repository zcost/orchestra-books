# Create Region

# Environment

Keyword | Value | Description
----    | ----  | ----
URL         | http://127.0.0.1/api/v1 | URL for request
USER_ID     | admin     | user_id for this system
PASSWORD    | password  | password for this system
OPENSTACK   | False     | If you don't want to test OpenStack, change to False
AWS         | False     | If you don't want to test AWS, change to False
BAREMETAL   | True      | Register Baremetal Region, Zone
JOYENT      | False     | Discover Joyent Region, Zone
REGION_NAME | ap-northeast-2    | Region name for Provisioning
ZONE_NAME   | zcost-1   | Zone name for servers

# Region/Zone

Automatic Discovery based on OpenStack account 

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

display('Auth')
url = '${URL}/token/get'
user_id='${USER_ID}'
password='${PASSWORD}'
body = {'user_id':user_id, 'password':password}
token = makePost(url, header, body)
token_id = token['token']
header.update({'X-Auth-Token':token_id})


display('Discovery Zone')
url = '${URL}/provisioning/discover'

if ${OPENSTACK}:
    display('Discover OpenStack Cloud Infra')
    keystone = raw_input('Keystone url(ex. http://10.1.0.1:5000/v2.0): ')
    tenant_name = raw_input('Tenant Name: ')
    username = raw_input('User ID: ')
    password = raw_input('Password: ')
 
    body = {
        "discover": {
            "type":"openstack",
            "keystone":keystone,
            "auth":{
               "tenantName": tenant_name,
               "passwordCredentials":{
                  "username": username,
                  "password": password
               }
            }
        }
    }

    discover = makePost(url, header, body)

if ${AWS}:
    display('Add AWS Cloud User info')
    a_key = raw_input('AWS Access Key ID: ')
    sa_key = raw_input('AWS Secret Access Key: ')
 
    body = {
        "discover": {
            "type":"aws",
            "auth":{
               "access_key_id": a_key,
               "secret_access_key": sa_key
            }
        }
    }

    discover = makePost(url, header, body)

if ${JOYENT}:
    display('Discover Joyent Cloud resources')
    a_key = raw_input('Key ID: ')
    s_key = raw_input('Secret path: ')
 
    body = {
        "discover": {
            "type":"joyent",
            "auth":{
               "key_id": a_key,
               "secret": s_key
            }
        }
    }

    discover = makePost(url, header, body)



if ${BAREMETAL}:
    display('List Regions')
    url = '${URL}/provisioning/regions'
    show(makeGet(url, header))
    #yn = raw_input('Use region(y/n)?')
    yn = 'n'
    if yn == 'y':
        region_id = raw_input("Region ID: ")
    else:
        display('Add Baremetal Region & Zone')
        #region_name = raw_input('region name: ')
        region_name = "${REGION_NAME}"
        body = {'name':region_name}
        r_url = '${URL}/provisioning/regions'
        region = makePost(r_url, header, body)
        show(region)
        region_id = region['region_id']

    #zone_name = raw_input('Zone name: ')
    zone_name = "${ZONE_NAME}"
    body = {'name':zone_name, 'region_id':region_id, 'zone_type':'baremetal'}
    z_url = '${URL}/provisioning/zones'
    zone = makePost(z_url, header, body)
    show(zone)

    zone_name = "management"
    body = {'name':zone_name, 'region_id':region_id, 'zone_type':'baremetal'}
    z_url = '${URL}/provisioning/zones'
    zone = makePost(z_url, header, body)
    show(zone)

   
display('List Regions')
url = '${URL}/provisioning/regions'
show(makeGet(url, header))

display('List Zones')
url = '${URL}/provisioning/zones'
show(makeGet(url, header))
~~~
