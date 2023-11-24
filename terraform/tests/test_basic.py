# SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

import os


def test_packages_are_installed(host):
    packages = [
        "git",
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


def test_ssh_is_listening(host):
    socket = host.socket(f"tcp://0.0.0.0:22")
    assert socket.is_listening


def test_ufw_service_running_and_enabled(host):
    service = host.service("ufw")
    assert service.is_running
    assert service.is_enabled


def test_ssh_service_running_and_enabled(host):
    service = host.service("ssh")
    assert service.is_running
    assert service.is_enabled


def test_ssh_is_installed(host):
    pkg = host.package("openssh-server")
    assert pkg.is_installed
