FROM opensuse/leap:15.3
LABEL maintainer="Tim Gruetzmacher"

ENV container docker

RUN zypper install -y dbus-1 systemd-sysvinit
RUN cp /usr/lib/systemd/system/dbus.service /etc/systemd/system/; \
    sed -i 's/OOMScoreAdjust=-900//' /etc/systemd/system/dbus.service

# Install dependencies.
RUN zypper -n install sudo python3 python3-pip python3-setuptools python3-wheel

# Upgrade pip to latest version.
RUN pip3 install --upgrade pip

# Install Ansible via pip.
ENV pip_packages "ansible cryptography"

RUN pip3 install $pip_packages

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Create `ansible` user with sudo permissions
ENV ANSIBLE_USER=ansible

RUN set -xe \
  && useradd -m ${ANSIBLE_USER} \
  && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
