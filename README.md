
Making the pre-AMI instance

    Services -> Networking -> VPC
    create: vpc-cloudflare
    172.31.0.0/16
    Edit after creating Make sure to auto-assign public ips
    DNS resolution: yes
    DNS hostnames: yes

    create: subnet-cloudflare
    AZ: No preference
    172.31.16.0/20

    EC2 Dashboard
    ami-916f59f4 - Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
    t2.micro


    cloudflare-sg
    ssh,http,httpd all

Log in and

    sudo bash
    git clone https://github.com/tsugicloud/ami.git
    cd ami
    bash pre-ami.sh
    systemctl poweroff

Make the AMI in AWS console

Make a new instance from the AMI

Put in the user data under Advanced


After the new instance comes up you can look at the trail at:

    /var/log/cloud-init-output.log


About EFS and /etc/fstab

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot-old.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-update-fstab

