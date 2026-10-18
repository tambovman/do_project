Ansible now manages:
- common packages on all hosts
- Docker on jenkins, agent01, app01, and monitoring
- Node Exporter on all hosts
- application prerequisites on app01
- Jenkins agent prerequisites on agent01
- the whole lab through site.yml

The main rebuild command is now:
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/site.yml