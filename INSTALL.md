# Install

<!-- TOC titleSize:2 tabSpaces:2 depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 skip:1 title:1 charForUnorderedList:* -->
## Table of Contents
* [Goal](#goal)
* [Ubuntu](#ubuntu)
  * [Notes](#notes)
* [MacOs](#macos)
  * [with asdf](#with-asdf)
    * [Install ruby and hiera-eyaml](#install-ruby-and-hiera-eyaml)
    * [Install python 3.6.8](#install-python-368)
  * [with brew](#with-brew)
    * [Installation de Ansible](#installation-de-ansible)
    * [Installation de Ruby](#installation-de-ruby)
    * [Installation de hiera-eyaml](#installation-de-hiera-eyaml)
    * [Installation de bcrypt](#installation-de-bcrypt)
    * [Installation de nickjj.docker](#installation-de-nickjjdocker)
<!-- /TOC -->


## Goal
```
$ ansible --version
ansible 2.8.4
  config file = /home/user/Dev/external-noc/ansible/ansible.cfg
  configured module search path = ['/home/user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/user/.local/lib/python3.6/site-packages/ansible
  executable location = /home/user/.local/bin/ansible
  python version = 3.6.8 (default, Aug 20 2019, 17:12:48) [GCC 8.3.0]
```


## Ubuntu

```
$ sudo apt install -y python3 python3-pip hiera-eyaml
$ sudo -H pip3 install ansible bcrypt
$ ansible-galaxy install nickjj.docker
```

### Notes

If py-bcrypt module is installed, you may want to apply this patch:
```
diff --git a/ansible/filter_plugins/htpasswd.py b/ansible/filter_plugins/htpasswd.py
index 67c155f..5ee2ef2 100644
--- a/ansible/filter_plugins/htpasswd.py
+++ b/ansible/filter_plugins/htpasswd.py
@@ -14,11 +14,11 @@ import re
 def htpasswd(arg, resalt=False, path='/tmp/ansible_htpasswd_salt.txt'):
   if (resalt or not os.path.exists(path)):
     salt = gensalt()
-    f = open(path,"w")
+    f = open(path,"wb")
     f.write(salt)
     f.close()
   else:
-    f = open(path, "r")
+    f = open(path, "rb")
     salt = f.read()
     f.close()

@@ -27,6 +27,7 @@ def htpasswd(arg, resalt=False, path='/tmp/ansible_htpasswd_salt.txt'):
   for up in ups:
     u, p = up.split(":")
     ep = hashpw(bytes(p, 'utf-8'), salt)
+    ep = str(ep, 'utf-8')
     ueps.append("%s:%s" % (u, ep))
   output = ", ".join(ueps)
   output = re.sub('\$', '$$', output)
```

## MacOs

### with asdf

#### Install ruby and hiera-eyaml

```
asdf install ruby $(grep python .tool-versions | cut -d ' ' -f 2)
asdf reshim ruby
gem install hiera-eyaml
```

####  Install python 3.6.8
For this task I suggest to use either [pyenv](https://github.com/pyenv/pyenv)
or [asdf](https://github.com/asdf-vm/asdf). The latter is more cumbersome 
because as it lacks support for virtual environments. I suggest to use it in 
combination with [pipenv](https://github.com/pypa/pipenv)

```
asdf install python $(grep python .tool-versions | cut -d ' ' -f 2)
pip install --upgrade pip
pip install pipenv
asdf reshim python
cd ansible
pipenv install 
```

this will install the correct python version and all the necessary packages in 
a virtual python environment. Before running ansible, you will need to 
**activate** the environment with 

```
pipenv shell
ansible-playbook etc.
```


### with brew
Cette procédure fonctionne sur un macbook pro avec Catalina (zf200330.1915)

#### Installation de Ansible
```
brew install ansible
```

#### Installation de Ruby
```
brew install ruby
```

#### Installation de hiera-eyaml
```
sudo gem install hiera-eyaml
```

#### Installation de bcrypt
```
sudo -H pip3 install bcrypt
```

#### Installation de nickjj.docker
```
ansible-galaxy install nickjj.docker
```

