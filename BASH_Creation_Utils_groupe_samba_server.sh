#!/bin/bash
# Nom de famille: Belony
# Prénom: Carlens
# Matricule: 1826732
# 16 Décembre 2021
# Script de l'examen final

# création des groupes
groupadd grprojet
groupadd grdev

# création des utilisateurs projet avec mot de passe
for VAR in $(seq -w 01 10)
do
        useradd -s /bin/bash -g grprojet -m projet$VAR
        su -c "echo -e 'Secret1\nSecret1' | passwd projet$VAR"
done

# création des utilisateurs python et java avec mot de passe
mkdir /programmeurs/
        useradd -s /bin/bash -g grdev -m -d /programmeurs/java/ java
        useradd -s /bin/bash -g grdev -m -d /programmeurs/python/ python
        su -c "echo -e 'Secret1\nSecret1' | passwd java"
        su -c "echo -e 'Secret1\nSecret1' | passwd python"

# Autorisations du dossier programmeurs
chown root:root /programmeurs/
chmod 755 /programmeurs/

#création et autorisations des dossier /infodev/
mkdir /infodev/
chmod 755 /infodev/
chown python:grdev /infodev/

#création des mot de passes Secret1 pour Samba

        su -c "echo -e 'Secret1\nSecret1' | smbpasswd -s -a java"
        su -c "echo -e 'Secret1\nSecret1' | smbpasswd -s -a python"

# création du partage test du dossier Distro

chmod 775 /infodev/
chown python:grdev /infodev/

echo "[dev]" >> /etc/samba/smb.conf
echo "comment = partage de l'examen final" >> /etc/samba/smb.conf
echo "path = /infodev/" >> /etc/samba/smb.conf
echo "writable = yes" >> /etc/samba/smb.conf
echo "browsable = yes" >> /etc/samba/smb.conf
echo "valid users = +grdev" >> /etc/samba/smb.conf
echo "public = no" >> /etc/samba/smb.conf

