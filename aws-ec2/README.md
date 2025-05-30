# terraform-study
The repo for practicing terraform

after the reboot perform below steps:

- sudo usermod -aG docker $USER && newgrp docker
- cd /usr/local/bin
- kubectl version -o yaml
- minikube start - vm-driver=docker

-----------------------------------------------------------------------------------
to install kubectl 1.33

curl -LO https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl

Validate the kubectl binary against the checksum file:

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

If you do not have root access on the target system, you can still install kubectl to the ~/.local/bin directory:

chmod +x kubectl
mkdir -p ~/.local/bin
#mv ./kubectl ~/.local/bin/kubectl 
cp ./kubectl ~/.local/bin/kubectl 
# and then append (or prepend) ~/.local/bin to $PATH
