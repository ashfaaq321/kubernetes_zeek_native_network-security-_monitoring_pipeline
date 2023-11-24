# SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

import os


def test_packages_are_installed(host):
    packages = [
        "nginx",
        "ufw",
        "git",
        "nginx",
        "wget",
        "curl",
        "gpg",
        "ca-certificates",
        "zip",
        "python3-pip",
        "virtualenv",
        "python3-setuptools",
    ]
    for p in packages:
        print(f"[*] Checking if {p} is installed")
        pkg = host.package(p)
        assert pkg.is_installed



def test_nginx_service_running_and_enabled(host):
    service = host.service("nginx")
    assert service.is_running
    assert service.is_enabled

def test_config_is_present(host):
    file = host.file("/etc/nginx/sites-available/nginx.cfg")
    assert file.exists
    assert file.is_file

    sym_file = host.file("/etc/nginx/sites-enabled/default")
    assert sym_file.exists
    assert sym_file.is_symlink
    assert sym_file.linked_to  == file

def test_nginx_is_listening(host):
    socket = host.socket(f"tcp://0.0.0.0:80")
    assert socket.is_listening
