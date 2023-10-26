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

## Détails

### Analyse des Répertoires


Répertoire `src`


Le répertoire `src` contient deux sous-répertoires :

- `impl` : Implémentation du noyau.
- `intf` : Interfaces ou définitions d'API.


Répertoire `targets`


Le répertoire targets contient un seul sous-répertoire :
- `x86_64` : Le noyau est destiné à la plateforme x86_64, d'où l'utilisation de QEMU pour l'émulation de cette architecture.

## Structure du Projet
`src/impl`: Contient l'implémentation du noyau, y compris les détails spécifiques à l'architecture x86_64.
`src/intf`: Définit les interfaces, comme print.h pour l'affichage ou la journalisation.
`targets/x86_64`: Inclut les scripts et configurations pour la construction et le lien de l'ISO du noyau pour x86_64.


## Explications

Un "kernel" (ou noyau, en français) est l'une des parties les plus fondamentales d'un système d'exploitation. Il sert d'intermédiaire entre le logiciel applicatif et le matériel informatique. Le noyau a plusieurs responsabilités cruciales, dont voici quelques-unes:

- Gestion de la mémoire : Le noyau est responsable de la gestion de la mémoire RAM, y compris la mémoire pour les processus en cours d'exécution et la gestion de la mémoire virtuelle.
- Planification des processus : Il décide quel processus doit être exécuté par le processeur, quand et pendant combien de temps.
- Gestion des périphériques : Il communique directement ou via des pilotes de périphériques avec le matériel externe comme les disques durs, les claviers, les imprimantes, etc.
- Gestion des systèmes de fichiers : Le noyau permet aux programmes et aux utilisateurs d'accéder aux fichiers sur les disques de stockage.
- Gestion des entrées/sorties (I/O) : Il facilite la communication entre les logiciels internes et les périphériques externes.
- Mise en réseau : Le noyau gère les communications réseau et les protocoles associés.
- Sécurité et Accès : Il assure que les ressources non autorisées ne sont pas accessibles et isole les processus pour éviter les interférences.


Dans le contexte de ce projet que nous avons examiné, le terme "kernel" est utilisé car le code est conçu pour interagir directement avec le matériel sous-jacent, sans dépendre d'un autre système d'exploitation ou noyau. Lorsqu'un code a cette capacité et cette responsabilité, il est généralement considéré comme un noyau.

### Différence entre un noyau et un système d'exploitation complet
Bien que le noyau soit une partie essentielle d'un système d'exploitation, il ne constitue pas à lui seul un système d'exploitation complet. Un système d'exploitation complet comprend généralement des utilitaires, des programmes d'application, des interfaces utilisateur (comme des GUI) et d'autres fonctionnalités qui rendent le système utilisable pour les tâches quotidiennes. Le noyau, en revanche, est le cœur qui rend toutes ces fonctionnalités possibles en interagissant directement avec le matériel.

En résumé, le projet est un noyau de base, pour comprendre comment ces fonctions essentielles sont gérées au niveau le plus bas d'un système d'exploitation dans un but éducatif.
