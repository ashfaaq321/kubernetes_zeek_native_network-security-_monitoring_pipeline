#!/bin/bash


for vm in $(virsh list --all --name --state-shutoff); do \
	echo "[*] Starting vm: $vm"; \
	virsh start $vm; \
done
