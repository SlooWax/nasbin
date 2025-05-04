# NasBin
This is college project for every-year coursework for system and networking administration course.

## Why this? 
My alma-matter often provides a master class for people for try-in-moment to be a system administrator and give it a Proxmox VE machine with 2 VM inside on 1-2 hour.

1. Debian Server {ISP} with static IP address in virtual network linux bridge and on it some guy need to setup isc-dhcp server and check result on CLI machine
2. CLI Machine - small windows machine just to check connection to internet and watch ipconfig status

## How Run?

First at all - teacher (or you) edit data in ```inventory.ini``` file variables to connect a Central Proxmox VE server or cluster and edit in ```PVEC.yaml``` count of VMs it needed and run Ansible playbook via

    ansible-playbook -i inventory.ini PVEC.yaml

And wait some time (On my home server Dell PowerEdge R630 with HDD in zraid5 it takes 20 min/PVE), but time depends from your internet connection and powerful of hardware and it configuration.

> *P.s For privacy i cleared up links to shell script and qcow/iso images. You need to edit this too. I recommend try use local intranet
> http/https server for this stuff. If you want to fuck with all this - try use NFS/Samba-share*
## FAQ

-Why you did it through this strange system?
-Because it did for hard requirements and method using cloudinit or Proxmox Template system doesn't
satisfies these requirements