Troubleshooting kubectl-ai with Ollama on AWS EC2 t3.large
Use Case: The goal was to set up kubectl-ai to integrate with Ollama and the llama3 Large Language Model (LLM) on an AWS EC2 t3.large instance (8GB RAM, 20GB attached volume at /mnt/data) to generate Kubernetes YAML configurations.

Problem 1: Root Filesystem Full (/) During Ollama Installation/Editing (E514: Write error)
Observation/Error: When trying to edit ollama.service or during Ollama installation, received errors like "ollama.service" E514: Write error (file system full?)" and similar No space left on device messages.
Diagnostic Steps:
Used df -h to check disk usage, which showed the root filesystem (/dev/root) at 100% utilization.
Used sudo du -sh /* | sort -rh | head -n 10 and then sudo du -sh /usr/local/lib* | sort -rh | head -n 10 to pinpoint the largest directories.
Discovered 3.2G of data within /usr/local/lib/ollama/.
Root Cause: The Ollama installation script, by default, placed its core large libraries directly onto the root filesystem (/usr/local/lib/ollama), consuming a significant portion of the small 8GB root volume.
Solution:
Stopped the Ollama service: sudo systemctl stop ollama.
Created a dedicated directory on the larger volume: sudo mkdir -p /mnt/data/ollama_libraries.
Moved the large Ollama library directory: sudo mv /usr/local/lib/ollama /mnt/data/ollama_libraries/.
Created a symbolic link from the original path to the new location: sudo ln -s /mnt/data/ollama_libraries/ollama /usr/local/lib/ollama.
Set correct permissions for the moved data: sudo chown -R root:root /mnt/data/ollama_libraries/ollama and sudo chmod -R 755 /mnt/data/ollama_libraries/ollama.
Configured Ollama's systemd service to store models on the larger volume: sudo systemctl edit --full ollama.service and added Environment="OLLAMA_MODELS=/mnt/data/ollama_models" under [Service].
Reloaded systemd and started Ollama: sudo systemctl daemon-reload && sudo systemctl start ollama.
Result: Root filesystem usage dropped significantly to 43%.


Problem 2: Root Filesystem Still High - /usr/share/ollama Large
Observation/Error: Despite the previous fix, the root filesystem was still consuming too much space, hindering operations.
Diagnostic Steps:
Ran sudo du -sh /usr/share/* | sort -rh | head -n 10 which showed /usr/share as 4.2G.
Further investigation confirmed 3.9G was specifically in /usr/share/ollama/.
Root Cause: Similar to Problem 1, the main Ollama application binary and potentially other default components were installed in /usr/share/ollama, still consuming space on the root filesystem.
Solution:
Stopped the Ollama service: sudo systemctl stop ollama.
Created a new directory on the data volume: sudo mkdir -p /mnt/data/ollama_app_data.
Moved the large Ollama application directory: sudo mv /usr/share/ollama /mnt/data/ollama_app_data/.
Created a symbolic link: sudo ln -s /mnt/data/ollama_app_data/ollama /usr/share/ollama.
Set correct permissions: sudo chown -R root:root /mnt/data/ollama_app_data/ollama and sudo chmod -R 755 /mnt/data/ollama_app_data/ollama.
Reloaded systemd and started Ollama: sudo systemctl daemon-reload && sudo systemctl start ollama.
Result: Disk space on / was finally in a healthy state.


Problem 3: kubectl-ai Hangs/Very Slow (Memory Over-subscription with llama3)
Observation/Error: After resolving disk space, kubectl-ai --model llama3 would hang indefinitely or take an extremely long time to respond (e.g., for "create a deployment for nginx"). ollama run llama3 worked but was slow.
Diagnostic Steps:
Used top and free -h to monitor RAM usage.
Observed very high RAM utilization (~6.6GiB used out of 7.6GiB total, with only ~1.0GiB available) when both Minikube (allocated 6GB) and Ollama (llama3 model, requiring ~5-6GB) were running.
Noticed CPU was active (~50% us) but not fully saturated, indicating a bottleneck elsewhere (memory pressure).
Confirmed 0.0 swap used, meaning the system was avoiding swapping but struggling with in-memory operations.
Root Cause: Insufficient RAM. The t3.large instance (8GB RAM) could not simultaneously accommodate Minikube (6GB allocation) and the llama3 model (5-6GB requirement). Total demand (11-12GB) significantly exceeded physical RAM (8GB).
Initial Proposed Solution (to mitigate RAM): Reduce Minikube's memory allocation to 4096mb (4GB).


Problem 4: Minikube permission denied for its home directory
Observation/Error: When trying minikube start --memory=4096mb, received Error creating minikube directory: mkdir /mnt/data/minikube_home/.minikube: permission denied.
Diagnostic Steps:
Used ls -ld /mnt/data/minikube_home which showed the directory was owned by root:root.
Root Cause: The ubuntu user, running minikube start, did not have write permissions to create files within the root-owned /mnt/data/minikube_home directory.
Solution:
Changed ownership: sudo chown -R ubuntu:ubuntu /mnt/data/minikube_home.
Set permissions: sudo chmod -R 775 /mnt/data/minikube_home.
Result: Minikube started successfully with 4GB RAM.


Problem 5: kubectl-ai Still Very Slow (Memory Limits with llama3 & 4GB Minikube)
Observation/Error: Even with Minikube at 4GB, kubectl-ai using llama3 was still extremely slow for simple requests.
Diagnostic Steps:
free -h still showed very low available RAM (~1.0GiB), even with Minikube consuming 2GB less.
Root Cause: Despite Minikube's reduced memory, the combined RAM demand of Minikube (4GB) and llama3 (5-6GB) still exceeded the 8GB physical RAM. The system was still under severe memory pressure.
Proposed Solution: Switch to a smaller LLM model that requires less RAM, such as phi3 (~2-3GB).


Problem 6: ollama pull phi3 Gives permission denied (Model storage permissions)
Observation/Error: When attempting ollama pull phi3, received Error: open /mnt/data/ollama_models/blobs/...partial-0: permission denied. This occurred even after setting ollama_models to ubuntu:ubuntu ownership.
Diagnostic Steps:
Used sudo systemctl cat ollama.service | grep User= which revealed User=ollama.
Root Cause: The ollama daemon (running as the dedicated ollama user, not ubuntu) was the process trying to write the model files to /mnt/data/ollama_models. Since the directory was owned by ubuntu, the ollama user did not have write permissions.
Solution:
Stopped Ollama service: sudo systemctl stop ollama.
Changed ownership of the model directory to the ollama user: sudo chown -R ollama:ollama /mnt/data/ollama_models.
Set permissions: sudo chmod -R 775 /mnt/data/ollama_models.
Removed any partial download files: sudo rm -f /mnt/data/ollama_models/blobs/*partial*.
Started Ollama service: sudo systemctl start ollama.
Result: ollama pull phi3 was able to successfully download the model.
Key Learning Points from This Troubleshooting Journey:
Disk Space vs. RAM: These are distinct but interconnected resources. A full disk blocks writes and basic operations, while insufficient RAM leads to extreme slowness and hangs.
Importance of df -h and du -sh: Always the first tools for disk space issues. df gives overall, du identifies culprits.
Symbolic Links for Large Data: Essential for moving large application data (like LLM models or application binaries) off small root partitions to larger attached volumes without breaking application paths.
Permissions are Paramount: Linux permissions (chown, chmod) are critical. Always ensure the user that is attempting to perform an action (whether directly or via a background service) has the necessary permissions for the target files/directories. The User= directive in systemd service files is crucial for services.
Memory Management for LLMs: Large language models like llama3 are very RAM-intensive. When running them on a VM or cloud instance, you must account for the RAM requirements of the LLM itself, the VM/container runtime (e.g., Minikube's allocated RAM), and the host OS. Oversubscription leads to severe performance degradation.
Systematic Troubleshooting: Start with the most obvious errors, use diagnostic tools, identify the root cause, apply targeted solutions, and then re-evaluate.
Patience and Persistence: Troubleshooting can be a long and iterative process, requiring patience and a willingness to try different approaches.