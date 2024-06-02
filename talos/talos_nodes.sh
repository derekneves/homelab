#!/bin/bash
# USage (local): talos_node.sh vm_id
# Usage (remote): cat talos_nodes.sh | ssh root@192.168.0.102 "bash -s -- 102"


# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <vm_id>"
    exit 1
fi

# Assign the first argument to vm_id
vm_id=$1
# Check if the VM with the specified ID already exists
if qm status $vm_id &> /dev/null; then
    echo "A VM with ID $vm_id already exists. Aborting to prevent duplication."
    exit 1
fi

# Generate a random 5-character alphanumeric string
rand_node_hash=$(tr -dc 'a-z0-9' </dev/urandom | head -c 5)

# Create the VM with a random name suffix and specific configuration
qm create $vm_id --name k8s-node-$rand_node_hash --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0 --cpu x86-64-v2-AES
sleep 1

# Configure VM storage
qm set $vm_id --scsihw virtio-scsi-pci --scsi0 local-lvm:32
sleep 1

# Set the CD-ROM with the ISO
qm set $vm_id --ide2 local:iso/metal-amd64.iso,media=cdrom
sleep 1

# Configure the boot order
qm set $vm_id --boot order="scsi0;ide2"

qm start $vm_id

echo Node: k8s-node-$rand_node_hash was created.