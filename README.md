In this project Terraform is gonna create ssh key, security group , 2 instances named as loadbalancer and database, launch configuration
as plain Ubuntu Server 18.04 LTS, auto sclaling group and auto scaling policy in which if CPU gets over 60% its gonna create new instance.
Ansible is gonna configure database, webservers, loadbalancer. Also in this script its gonna run constantly ec2.py script which creates
dynamic host file and if the output is different from the last one its gonna start another ansible playbook which will configure new
webserver create new user in database and add new server to a loadbalancer.

To run the script you need to create aws user with secret key. Also you obviously need to have ansible, terraform and both python, python3
  You need to install such python modules: boto and ansible with use of pip for both pythons. And you need to have user that can run terraform
and ansible.

Command to run the script: python setup.py << AWS_ACCESS_KEY_ID >> << AWS_SECRET_ACCESS_KEY >> << AWS_DEFAULT_REGION >> &

Script is going to print out terraform and first ansible configuration. After that if everytihg runs smoothly you can start doing
anything you want because it's running in the background.
