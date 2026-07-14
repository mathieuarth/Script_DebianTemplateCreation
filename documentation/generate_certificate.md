# Using a classic SSH key with Cloud-Init on Proxmox

This is a simpler approach, without a certificate, to authenticate SSH connections to a Debian template created with Cloud-Init on Proxmox.

## 1. Generate a classic SSH key

On your client machine, create an SSH key if you do not already have one:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "comment"
```

Explanation of the options:

- `-t ed25519`: selects a modern and robust key algorithm
- `-f ~/.ssh/id_ed25519`: defines the path and file name of the key
- `-N ""`: sets an empty passphrase, so no passphrase is requested
- `-C "comment"`: adds a comment to help identify the key

This creates:

- `~/.ssh/id_ed25519`
- `~/.ssh/id_ed25519.pub`

## 2. Add the public key to the template or VM

The public key must be added to the target machine in the `~/.ssh/authorized_keys` file of the relevant user.

Example:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## 3. Configure the SSH server

On the Debian VM, verify that SSH accepts key-based connections:

```bash
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 4. Integrate the configuration into Cloud-Init

In your Proxmox template, you can inject the public key automatically via Cloud-Init.

Example Cloud-Init configuration:

```yaml
#cloud-config
users:
  - name: debian
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyYourPublicKeyHere
```

This method adds the key to the `debian` user when the VM is created.

## 5. Add the key when creating the template with Proxmox

If you want to inject the key directly when creating the template or VM from Proxmox, you can use the following command:

```bash
qm set 100 --ciuser debian --sshkeys /root/.ssh/authorized_keys
```

Explanation:

- `100`: Proxmox VM or template ID
- `--ciuser debian`: Cloud-Init user to configure
- `--sshkeys /root/.ssh/authorized_keys`: path to the file containing the public key to inject

If you want to use an external file:

```bash
qm set 100 --ciuser debian --sshkeys /path/to/id_ed25519.pub
```

You can also prepare the file with:

```bash
cat ~/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
```

## 6. Connect over SSH

From your client machine:

```bash
ssh debian@vm_ip
```

If you want to specify the key explicitly:

```bash
ssh -i ~/.ssh/id_ed25519 debian@vm_ip
```

## 7. Use the key with PuTTY

If you use PuTTY on Windows:

1. Open PuTTYgen.
2. Click Load.
3. Select your OpenSSH private key (`id_ed25519` or `id_rsa`).
4. Click Save private key.
5. Save the `.ppk` file.
6. In PuTTY, go to Connection > SSH > Auth and choose this `.ppk` file.
7. Connect to the VM IP address.

## Important notes

- This method is simple and widely used.
- It does not require a CA or certificate.
- It is suitable for a Proxmox template and for quick use in production or a lab environment.
- If you want to automate template recreation, you can use [schedule_template_rebuild.sh](schedule_template_rebuild.sh) to add a weekly cron job.
