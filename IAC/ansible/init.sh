#!/bin/bash


ansible live \
        -m ansible.builtin.ping \
        -i ./ansible/inventory 

ansible live \
        -m ansible.builtin.apt \
        -f 10 \
        -a "update_cache=yes upgrade=safe" \
        -i ./ansible/inventory/


ansible live \
        -m ansible.builtin.apt \
        -f 10 \
        -a "name=git,curl,wget,vim,zip" \
        -i ./ansible/inventory/




