resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile

  user_data = <<-EOF
    #!/bin/bash
    set -e

    yum update -y

    # Install Java (Jenkins dependency)
    amazon-linux-extras install java-openjdk11 -y

    # Add Jenkins repo
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    # Install Jenkins
    yum install jenkins -y

    # Enable & start Jenkins
    systemctl enable jenkins
    systemctl start jenkins

    # Prepare SSH key for Jenkins agents
    mkdir -p /home/jenkins/.ssh

    cat > /home/jenkins/.ssh/id_rsa <<'KEY'
${var.jenkins_nodes_private_key}
KEY

    chown -R jenkins:jenkins /home/jenkins/.ssh
    chmod 600 /home/jenkins/.ssh/id_rsa
  EOF

  tags = {
    Name = var.instance_name
  }
}
