# Utiliser une clé SSH classique avec Cloud-Init sur Proxmox

Voici une version plus simple, sans certificat, pour authentifier une connexion SSH vers un template Debian créé avec Cloud-Init sur Proxmox.

## 1. Générer une clé SSH classique

Sur votre poste client, créez une clé SSH si elle n’existe pas :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "commentaire"
```

Explication des options :

- `-t ed25519` : choisit l’algorithme de clé moderne et robuste
- `-f ~/.ssh/id_ed25519` : définit le chemin et le nom du fichier de clé
- `-N ""` : définit une phrase de passe vide, donc aucune passphrase n’est demandée
- `-C "commentaire"` : ajoute un commentaire à la clé pour mieux l’identifier

Cela crée :

- `~/.ssh/id_ed25519`
- `~/.ssh/id_ed25519.pub`

## 2. Ajouter la clé publique au template ou à la VM

La clé publique doit être ajoutée sur la machine cible dans le fichier `~/.ssh/authorized_keys` de l’utilisateur concerné.

Exemple :

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## 3. Configurer le serveur SSH

Sur la VM Debian, vérifiez que SSH accepte les connexions par clé :

```bash
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 4. Intégrer la configuration dans Cloud-Init

Dans votre template Proxmox, vous pouvez injecter la clé publique automatiquement via Cloud-Init.

Exemple de configuration Cloud-Init :

```yaml
#cloud-config
users:
  - name: debian
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyYourPublicKeyHere
```

Cette méthode permet d’ajouter la clé à l’utilisateur `debian` au moment de la création de la VM.

## 5. Ajouter la clé lors de la création du template avec Proxmox

Si vous voulez injecter la clé directement lors de la création du template ou de la VM depuis Proxmox, vous pouvez utiliser la commande suivante :

```bash
qm set 100 --ciuser debian --sshkeys /root/.ssh/authorized_keys
```

Explication :

- `100` : ID de la VM ou du template Proxmox
- `--ciuser debian` : utilisateur Cloud-Init à configurer
- `--sshkeys /root/.ssh/authorized_keys` : chemin du fichier contenant la clé publique à injecter

Si vous souhaitez utiliser un fichier externe :

```bash
qm set 100 --ciuser debian --sshkeys /path/to/id_ed25519.pub
```

Vous pouvez aussi préparer ce fichier avec :

```bash
cat ~/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
```

## 6. Se connecter en SSH

Depuis votre poste client :

```bash
ssh debian@ip_du_vm
```

Si vous souhaitez préciser la clé :

```bash
ssh -i ~/.ssh/id_ed25519 debian@ip_du_vm
```

## 7. Utiliser la clé avec PuTTY

Si vous utilisez PuTTY sur Windows :

1. Ouvrez PuTTYgen.
2. Cliquez sur Load.
3. Sélectionnez votre clé privée OpenSSH (`id_ed25519` ou `id_rsa`).
4. Cliquez sur Save private key.
5. Enregistrez le fichier `.ppk`.
6. Dans PuTTY, allez dans Connection > SSH > Auth, puis choisissez ce fichier `.ppk`.
7. Connectez-vous à l’adresse IP de la VM.

## Points importants

- Cette méthode est simple et largement utilisée.
- Elle ne requiert pas de CA ni de certificat.
- Elle est adaptée pour un template Proxmox et une utilisation rapide en production ou en laboratoire.
