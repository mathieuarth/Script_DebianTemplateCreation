# Module vm

## Rôle

Le module vm configure la VM finale à partir de l’image préparée et des paramètres définis au début du pipeline.

## Commandes utilisées

Le contenu réel du module est encore très minimal, mais il est prévu pour intégrer les étapes de création et de configuration de la machine virtuelle via Proxmox.

## Comportement attendu

Ce module intervient à la fin du pipeline et doit permettre :

- la création ou la mise à jour de la VM,
- l’association de l’image préparée à la VM,
- la définition du stockage, de la mémoire, des CPU et du réseau,
- la configuration du système final selon les options fournies.

## Conseils

Pour l’extension du projet, ce module est le bon endroit pour ajouter les commandes Proxmox telles que `qm create`, `qm set`, `qm start` ou `qm template`.
