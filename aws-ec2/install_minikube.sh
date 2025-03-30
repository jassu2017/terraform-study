#!/bin/bash

# PHASE 1: Pre-reboot setup
if [ ! -f /tmp/minikube_phase2 ]; then
    # Update system
    sudo apt update -y && sudo apt upgrade -y
    
    # Create phase 2 script
    cat << 'EOF' > /home/ubuntu/phase2.sh
	#!/bin/bash
	# PHASE 2: Post-reboot setup

	# Install Docker
	sudo apt install -y docker.io
	sudo usermod -aG docker $USER && newgrp docker

	# Install dependencies
	sudo apt install -y curl wget apt-transport-https

	# Install Minikube (single line without breaks)
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube

	# Install kubectl (single line without breaks)
	curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

	# Verify installations
	minikube version


	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

	chmod +x kubectl

	sudo mv kubectl /usr/local/bin

	kubectl version -o yaml

	minikube start - vm-driver=docker

	minikube status

	kubectl version

	kubectl version --client

	# Cleanup
	rm -- "$0"
	EOF

		# Make phase 2 executable
		chmod +x /home/ubuntu/phase2.sh
		
		# Create systemd service to run after reboot
		cat << 'EOF' | sudo tee /etc/systemd/system/minikube-phase2.service
    	[Unit]
    	Description=Minikube Phase 2 Installation
    	After=network.target
    
    	[Service]
    	Type=simple
    	ExecStart=/home/ubuntu/phase2.sh
    
    	[Install]
    	WantedBy=multi-user.target
    	EOF

		# Enable service and mark phase 1 complete
		sudo systemctl enable minikube-phase2.service
		touch /tmp/minikube_phase1
		
		# Reboot
		sudo reboot
fi
