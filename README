This is a little & basic OS kernel. 

To enter the build env:

Linux or MacOS: `docker run --rm -it -v "$(pwd)":/root/env myos-buildenv`
Windows (CMD): `docker run --rm -it -v "%cd%":/root/env myos-buildenv`
Windows (PowerShell): `docker run --rm -it -v "${pwd}:/root/env" myos-buildenv`

Launch emulation with Qemu:
```
C:\"Program Files"\qemu\qemu-system-x86_64.exe -cdrom dist/x86_64/kernel.iso
```
# Petit Noyau de Système d'Exploitation (OS)
Ce projet est un petit noyau de système d'exploitation, principalement conçu pour l'architecture x86_64. Il vise à fournir une base simple pour comprendre le fonctionnement interne des systèmes d'exploitation. Le noyau est divisé en interfaces (intf) et implémentations (impl), mettant l'accent sur la clarté et la modularité.

## Environnement de Développement
L'environnement de développement est basé sur Docker, ce qui permet une configuration et une compilation cohérentes, indépendamment de la plateforme sous-jacente (Linux/MacOS/Windows).

## Configuration de l'Environnement
Pour configurer l'environnement de développement, utilisez les commandes Docker suivantes selon votre système d'exploitation :

Linux/MacOS:
```sh
docker run --rm -it -v "$(pwd)":/root/env myos-buildenv
```

Windows (CMD):
```sh
docker run --rm -it -v "%cd%":/root/env myos-buildenv
```

Windows (PowerShell):
```sh
docker run --rm -it -v "${pwd}:/root/env" myos-buildenv
```

## Compilation
Utilisez le Makefile fourni pour compiler le projet :
```
make all
```
Cela générera les fichiers exécutables et les images nécessaires dans le répertoire dist.

## Exécution et Test
Pour exécuter le noyau, utilisez QEMU, un émulateur de machine. Voici la commande pour démarrer le noyau à l'aide de QEMU :
```
C:\\"Program Files"\\qemu\\qemu-system-x86_64.exe -cdrom dist/x86_64/kernel.iso
```

## Structure du Projet
`src/impl`: Contient l'implémentation du noyau, y compris les détails spécifiques à l'architecture x86_64.
`src/intf`: Définit les interfaces, comme print.h pour l'affichage ou la journalisation.
`targets/x86_64`: Inclut les scripts et configurations pour la construction et le lien de l'ISO du noyau pour x86_64.
