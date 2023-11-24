# SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

import os


def test_packages_are_installed(host):
    packages = [
        "ufw",
        "docker-ce",
    ]
    for p in packages:
        print(f"[*] Checking if {p} is installed")
        pkg = host.package(p)
        assert pkg.is_installed

def test_docker_is_installed(host):
    keyring_dir = host.file("/etc/apt/keyrings")
    assert keyring_dir.exists
    assert keyring_dir.is_directory

def test_docker_is_installed(host):
    keyring_dir = host.file("/etc/apt/keyrings")
    assert keyring_dir.exists
    assert keyring_dir.is_directory


def test_ufw_service_running_and_enabled(host):
    service = host.service("ufw")
    assert service.is_running
    assert service.is_enabled

def test_libreddit_docker_img(host):
    libreddit = host.docker("libreddit")
    assert libreddit.is_running

def test_libreddit_is_listening(host):
    socket = host.socket(f"tcp://0.0.0.0:8080")
    assert socket.is_listening
