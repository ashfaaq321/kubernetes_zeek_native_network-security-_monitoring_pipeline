import os


def test_packages_are_installed(host):
    packages = [
        "ufw",
    ]
    for p in packages:
        print(f"[*] Checking if {p} is installed")
        pkg = host.package(p)
        assert pkg.is_installed

def test_ssh_is_listening(host):
    socket = host.socket("tcp://192.168.122.238:22")
    assert socket.is_listening

def test_ufw_service_running_and_enabled(host):
    service = host.service("ufw")
    assert service.is_running
    assert service.is_enabled

def test_ssh_service_running_and_enabled(host):
    service = host.service("ssh")
    print(f"SSH service status:Running - {service.is_running},Enabled -{service.is_enabled}")
    assert service.is_running
    assert service.is_enabled



