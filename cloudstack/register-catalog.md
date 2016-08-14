# Unitest

## Environment

Keyword | Value         | Description
----    | ----          | ----
URL     | http://127.0.0.1/api/v1   | Orchestra API enpoint
REPO    | https://raw.githubusercontent.com/zcost/orchestra-books/master   | Repository if Orchestra books
USER_ID | admin         | User ID
PASSWORD| password      | Password for User ID

## Portfolio

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

url = '${URL}/catalog/portfolios'
display('List Portfolios')
show(makeGet(url, header))

display('Create Portfolio')
body = {'name':'Cloud', 'description':'Cloud IaaS Solution, OpenStack, CloudStack, and Docker',
        'owner':'choonho.son'}
portfolio = makePost(url, header, body)
show(portfolio)
p_id = portfolio['portfolio_id']
url = '${URL}/catalog/portfolios/%s' % p_id

######################################
# Product
######################################
product_url = '${URL}/catalog/products'
display('List Product')
show(makeGet(product_url, header))

display('Create Product')
body = {'portfolio_id':p_id, 'name':'CloudStack', 'short_description':'CloudStack cluster',
        'description':'CloudStack cluster', 'provided_by':'PyEngine',
        'vendor':'Apache org'}
product = makePost(product_url, header, body)
show(product)
product_id = product['product_id']
product_url2 = '${URL}/catalog/products/%s' % product_id

######################################
# Product Detail
######################################
detail_url = '${URL}/catalog/products/%s/detail' % product_id
display('Create Product detail')
body = {'email':'choonho.son@gmail.com', 'support_link':'${REPO}/cloudstack','support_description':'This is builded by Orchestra'}
show(makePost(detail_url, header, body))

######################################
# Package
######################################
package_url = '${URL}/catalog/packages'
body = {'product_id':product_id, 'pkg_type':'bpmn', 'template':'${REPO}/cloudstack/workflow.bpmn', 'version':'0.1', 'description':'https://raw.githubusercontent.com/zcost/orchestra-books/master/cloudstack/README.md'}
display('Create Package')
package = makePost(package_url, header, body)
package_id = package['package_id']
show(package)

######################################
# Register Workflow
######################################
display('Register Workflow')
workflow_url = '${URL}/catalog/workflows'
body = {'template':'${REPO}/cloudstack/workflow.bpmn', 'template_type':'bpmn'}
workflow = makePost(workflow_url, header, body)
workflow_id = workflow['workflow_id']
show(workflow)

######################################
# Map Task
######################################
display('Map Task #1')
task_url = '${URL}/catalog/workflows/%s/tasks' % workflow_id
body = {'map': {'name':'Prepare Information', 'task_type':'jeju', 'task_uri':'${REPO}/cloudstack/prepare.md'}}
task = makePost(task_url, header, body)
task_id = task['task_id']
show(task)

display('Map Task #2')
task_url = '${URL}/catalog/workflows/%s/tasks' % workflow_id
body = {'map': {'name':'Install NFS Server', 'task_type':'jeju@mnode', 'task_uri':'${REPO}/cloudstack/nfs-server.md'}}
task = makePost(task_url, header, body)
task_id = task['task_id']
show(task)

display('Map Task #3')
task_url = '${URL}/catalog/workflows/%s/tasks' % workflow_id
body = {'map': {'name':'Install CloudStack Management', 'task_type':'ssh@cloudstack01-vm', 'task_uri':'${REPO}/cloudstack/cloudstack-management.md'}}
task = makePost(task_url, header, body)
task_id = task['task_id']
show(task)


display('Map Task #4')
task_url = '${URL}/catalog/workflows/%s/tasks' % workflow_id
body = {'map': {'name':'Create Bonding Interface', 'task_type':'jeju@RACK01', 'task_uri':'${REPO}/cloudsack/cnode-network.md'}}
task = makePost(task_url, header, body)
task_id = task['task_id']
show(task)

display('Map Task #5')
task_url = '${URL}/catalog/workflows/%s/tasks' % workflow_id
body = {'map': {'name':'Install CloudStack Agent', 'task_type':'jeju@RACK01', 'task_uri':'${REPO}/cloudstack/cloudstack-agent.md'}}
task = makePost(task_url, header, body)
task_id = task['task_id']
show(task)

~~~
