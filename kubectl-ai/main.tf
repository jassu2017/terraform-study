resource "aws_vpc" "my-trfm-aws-vpc" {
  cidr_block       = "${var.vpc_cidr_block}"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "kubectl-ai-vpc"
  }


}


resource "aws_subnet" "my-trfm-aws-public-subnet" {
  vpc_id     = aws_vpc.my-trfm-aws-vpc.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "${var.region}a" # Use first AZ in your region

  tags = {
    Name = "kubectl-ai-subnet-pub"
  }

}

resource "aws_subnet" "my-trfm-aws-private-subnet" {
  vpc_id     = aws_vpc.my-trfm-aws-vpc.id
  cidr_block = "12.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    name = "kubectl-ai-subnet-pvt"
  }

}


resource "aws_internet_gateway" "my-trfm-aws-igw" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

  tags = {
    Name = "kubectl-ai-igw"
  }

}




resource "aws_route_table" "my-trfm-aws-public-rt" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-trfm-aws-igw.id
  }

  tags = {
    Name = "kubectl-ai-rt"
  }
}

resource "aws_route_table_association" "my-trfm-aws-rt-association-pub-sub" {
  subnet_id      = aws_subnet.my-trfm-aws-public-subnet.id
  route_table_id = aws_route_table.my-trfm-aws-public-rt.id
}

resource "aws_route_table" "my-trfm-aws-private-rt" {
  vpc_id = aws_vpc.my-trfm-aws-vpc.id

    tags = {
    Name = "my-trfm-aws-private-rt"
  }
}

resource "aws_route_table_association" "my-trfm-aws-rt-association-pvt-sub" {
  subnet_id      = aws_subnet.my-trfm-aws-private-subnet.id
  route_table_id = aws_route_table.my-trfm-aws-private-rt.id
}


resource "aws_security_group" "my-trfm-aws-sg" {
    name        = "my-trfm-aws-sg"
    description = "Allow SSH and Ollama ports"
    vpc_id      = aws_vpc.my-trfm-aws-vpc.id
    egress = [ 
        {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
     ]
     ingress = [
    {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]  
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
         
    {
      description      = "ICMP"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]  
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
        },

    {
    description = "Ollama default port from anywhere (if needed for external access)"
    from_port   = 11434
    to_port     = 11434
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict if Ollama is only used locally
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }

       
     ]

    tags = {
      name = "kubectl-ai-sg"
    }
  
}

resource "aws_instance" "my-trfm-aws-ec2" {
    ami           = "ami-00bb6a80f01f03502"
    instance_type = "t3.large"
    subnet_id = aws_subnet.my-trfm-aws-public-subnet.id
    associate_public_ip_address = true
    key_name = "demo-kubectl-ai"
    vpc_security_group_ids = [aws_security_group.my-trfm-aws-sg.id] 

    root_block_device {
    volume_size = 8  # Default 8 GiB
    volume_type = "gp3"
  }

  # --- User Data Script for setup ---
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    # --- 1. System Update and Dependencies ---
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

    # --- 2. Install Docker ---
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker ubuntu # Add current user to docker group
    newgrp docker # Apply group changes for current session

    # --- 3. Mount and Configure Extra Volume (20GB gp2) ---
    # This assumes the volume will be attached as /dev/xvdf or /dev/nvme1n1.
    # We'll use /dev/xvdh as per your previous lsblk output example.
    VOLUME_DEVICE="/dev/nvme1n1"
    MOUNT_POINT="/mnt/data"
    
    # Wait for the volume to be available
    while [ ! -e "$VOLUME_DEVICE" ]; do
        echo "Waiting for volume $VOLUME_DEVICE to be available..."
        sleep 5
    done

    # Format the volume if it's not already formatted (check if it has a filesystem)
    if ! sudo blkid "$VOLUME_DEVICE" | grep -q "TYPE="; then
      echo "Formatting $VOLUME_DEVICE..."
      sudo mkfs -t ext4 "$VOLUME_DEVICE"
    else
      echo "$VOLUME_DEVICE already has a filesystem. Skipping format."
    fi

    # Create mount point
    sudo mkdir -p "$MOUNT_POINT"

    # Mount the volume
    sudo mount "$VOLUME_DEVICE" "$MOUNT_POINT"

    # Make mount persistent by adding to fstab
    UUID=$(sudo blkid -s UUID -o value "$VOLUME_DEVICE")
    echo "UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

    # --- 4. Relocate Docker's Data Directory to new volume ---
    sudo systemctl stop docker
    sudo mv /var/lib/docker /mnt/data/docker_old_backup || true # Move existing, ignore if not found
    sudo mkdir -p /mnt/data/docker
    sudo ln -s /mnt/data/docker /var/lib/docker
    sudo systemctl start docker

    # --- 5. Install Minikube ---
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64

    # --- 6. Install kubectl ---
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    # --- 7. Install Ollama ---
    # Create symlink for Ollama's libraries before installing
    sudo mkdir -p /mnt/data/ollama_lib
    sudo mkdir -p /usr/local/lib # Ensure parent directory exists
    sudo ln -s /mnt/data/ollama_lib /usr/local/lib/ollama # This redirects Ollama's library installs

    curl -fsSL https://ollama.com/install.sh | sh

    # Set Ollama models directory to the new volume
    echo 'export OLLAMA_MODELS=/mnt/data/ollama_models' | sudo tee -a /etc/profile.d/ollama.sh
    echo 'export OLLAMA_MODELS=/mnt/data/ollama_models' >> ~/.bashrc # For current user

    # Create the directory for models
    sudo mkdir -p /mnt/data/ollama_models
    sudo chown -R ubuntu:ubuntu /mnt/data/ollama_models # Ensure ubuntu user has permissions

    # Restart Ollama service to pick up env var (if already running)
    sudo systemctl daemon-reload
    sudo systemctl restart ollama || true # Restart if it was running, ignore if not

    # --- 8. Install kubectl-ai ---
    # Find latest release tag (manually update KUBECTL_AI_VERSION if needed)
    # KUBECTL_AI_VERSION="v0.0.11" # Check https://github.com/GoogleCloudPlatform/kubectl-ai/releases for latest
    curl -LO "https://github.com/GoogleCloudPlatform/kubectl-ai/releases/download/v0.0.11/kubectl-ai_Linux_x86_64.tar.gz"
    ls -ltra
    tar -zxvf kubectl-ai_Linux_x86_64.tar.gz
    chmod a+x kubectl-ai
    sudo mv kubectl-ai /usr/local/bin/
    rm kubectl-ai_Linux_x86_64.tar.gz
    # Verify installation
    kubectl-ai --version

    # --- 9. Start Minikube Cluster ---
    # Ensure minikube starts after everything is set up
    # Create the new Minikube home directory on /mnt/data:
    mkdir -p /mnt/data/minikube_home
    #Set the MINIKUBE_HOME environment variable and persist it: You can add this to your ~/.bashrc file so it's always set for your ubuntu user.
    echo 'export MINIKUBE_HOME="/mnt/data/minikube_home"' >> ~/.bashrc
    #Apply the environment variable for the current session:
    source ~/.bashrc
    #Verify disk space again (optional, but good practice):
    df -h
    #Start minikube
    minikube start --vm-driver=docker --memory=6144mb # Allocate 6GB RAM to Minikube VM
    # The --force flag might not be needed once disk space is resolved
    # Use 6GB for Minikube, leaving 2GB for host OS and Ollama
    
    # Give it a moment to stabilize
    sleep 30
    
    # Pull a smaller Ollama model for kubectl-ai practice
    # This command uses the OLLAMA_MODELS env var we set
    ollama pull llama3 # Or mistral, gemma:2b if llama3 is still too much

    # --- 10. Configure kubectl-ai (for subsequent kubectl-ai runs) ---
    echo 'alias k="kubectl"' >> ~/.bashrc
    echo 'alias kai="kubectl-ai --llm-provider ollama --model llama3 --enable-tool-use-shim"' >> ~/.bashrc
    # Add other useful aliases
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc # Ensure local binaries are in path (if you install tools there)

    # Reload shell for aliases and path changes
    source ~/.bashrc

    echo "Initial setup complete! You can now run 'kai' or 'kubectl-ai --llm-provider ollama --model llama3 --enable-tool-use-shim' after SSHing in."
  EOF


    tags = {
      Name = "my-trfm-ec2-k8s"
    }
}

resource "aws_key_pair" "demo-key" {
    key_name = "demo-kubectl-ai"
    public_key = file("./demo-kubectl-ai.pub")
  
}

resource "aws_ebs_volume" "ec2-m-ebs-volume" {
  availability_zone = aws_subnet.my-trfm-aws-public-subnet.availability_zone
  size              = 20
  type              = "gp2" # You specified gp2

  tags = {
    Name = "kubectl-ai-extra-volume"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ec2-m-ebs-volume.id
  instance_id = aws_instance.my-trfm-aws-ec2.id
  force_detach =  true
}

