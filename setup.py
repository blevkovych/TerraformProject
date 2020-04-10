import os, sys, time
def AWS():
    KeyID = sys.argv[1]
    SecretKey = sys.argv[2]
    Region = sys.argv[3]
    credentials = ('export AWS_ACCESS_KEY_ID='+KeyID+' && export AWS_SECRET_ACCESS_KEY='+SecretKey+
    ' && export AWS_DEFAULT_REGION='+Region)
    return credentials

def ssh_key():
    if os.path.isfile('sshkey'):
        print('\n'"sshkey already exists no need to create new one")
    else:
        os.system("ssh-keygen -f sshkey -q -N ''")

def Terraform():
    credentials = AWS()
    os.system(credentials + ' && cd terraform && terraform init && terraform apply -auto-approve')

def Ansible():
    credentials = AWS()
    os.system(credentials + ' && cd ansible && python3 ec2.py && ansible-playbook -i ec2.py webservers.yml ' +
    '&& ansible-playbook -i ec2.py database.yml && ansible-playbook -i ec2.py loadbalancer.yml')
    print("--------------------------------")

def Autoscaling():
    credentials = AWS()
    ssh_key()
    Terraform()
    Ansible()
    output = os.popen(credentials + ' && python3 ansible/ec2.py').read()
    print('\n'"Autoscaling is enabled you can continue working from now on")
    while True:
        newoutput = os.popen(credentials + ' && python3 ansible/ec2.py').read()
        if newoutput != output:
            output = newoutput
            time.sleep(300)
            os.system(credentials + ' && cd ansible && nohup ansible-playbook -i ec2.py webservers.yml >/dev/null 2>&1 &')
            os.system(credentials + ' && cd ansible && nohup ansible-playbook -i ec2.py database.yml >/dev/null 2>&1 &')
            os.system(credentials + ' && cd ansible && nohup ansible-playbook -i ec2.py loadbalancer.yml >/dev/null 2>&1 &')
Autoscaling()
