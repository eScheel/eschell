FROM oraclelinux:9

# Update the OS and install required software.
RUN dnf update -y && dnf upgrade -y
RUN dnf install -y openssh openssh-server net-tools curl unzip wget python3 nmap nano cifs-utils

# ...
RUN mkdir /mnt/escheel-cloud-share
COPY ./bin/ /usr/local/bin/
RUN chmod +x -R /usr/local/bin/*

# Set insecure initial root password for ssh login.
RUN echo 'root:password' | chpasswd

# Configure ssh for access to the container.
EXPOSE 22/tcp
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
RUN touch /etc/banner
RUN echo '+-------------------+' >> /etc/banner
RUN echo '|eScheel Cloud Shell|' >> /etc/banner
RUN echo '+-------------------+' >> /etc/banner
RUN sed -i 's/#Banner none/Banner \/etc\/banner/' /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
CMD ["/usr/sbin/sshd", "-D"]

# Install Azure CLI.
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
RUN dnf install azure-cli

# Install AWS CLI.
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/root/awscliv2.zip"
RUN unzip "/root/awscliv2.zip" -d "/root/"
RUN ./root/aws/install
RUN rm -rv /root/*

# Install Terraform
RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform

# Install speedtest-cli
RUN wget -O /root/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py

