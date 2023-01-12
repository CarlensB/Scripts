﻿# ==========================================================================
$chemin = "\\S1\C$\_S1_PERSO"
$chemin2 = "\\S1\C$\_S1_INFO"

#Si ils existent déjà, on les supprime

$resultat = $(try {Get-Item $chemin} catch {$null})

$resultat = $(try {Get-Item $chemin2} catch {$null})


#On Crée le dossier _S1_PERSO

New-Item -Path $chemin `
         -ItemType directory

# S-1-5-18 est le SID pour "Système"
# S-1-3-4  est le SID pour "DROITS DU PROPRIÉTAIRE"

# On mets à jour les autorisations:
icacls.exe $chemin /inheritance:r
icacls.exe $chemin /grant "Administrateurs:(OI)(CI)(F)"
icacls.exe $chemin /grant "*S-1-5-18:(OI)(CI)(F)"
icacls.exe $chemin /grant "*S-1-3-4:(OI)(CI)(M)"
icacls.exe $chemin /grant "Utilisateurs du domaine:(RX)"

#On Crée le dossier _S1_INFO

New-Item -Path $chemin2 `
         -ItemType directory

# S-1-5-18 est le SID pour "Système"
# S-1-3-4  est le SID pour "DROITS DU PROPRIÉTAIRE"

# On mets à jour les autorisations:
icacls.exe $chemin2 /inheritance:r
icacls.exe $chemin2 /grant "Administrateurs:(OI)(CI)(F)"
icacls.exe $chemin2 /grant "*S-1-5-18:(OI)(CI)(F)"
icacls.exe $chemin2 /grant "*S-1-3-4:(OI)(CI)(M)"
icacls.exe $chemin2 /grant "Utilisateurs du domaine:(RX)"






#On partage le dossier PERSO--------------------------------------------------
New-SMBShare -Name "_S1_PERSO$" `
             -Path "C:\_S1_PERSO" `
             -FullAccess "Tout le monde" `
             -FolderEnumerationMode AccessBased `
             -CachingMode none `
             -CIMSession "S1"



  New-Item -Path "\\S1\_S1_PERSO$\$Matricule" `
    -ItemType directory

#On crée et assigne les autorisations des dossiers de départements------------

if ($Type_Employe -eq "EMPLOYES"){
    icacls.exe \\S1\C$\_S1_INFO\$Domaine /grant  `
                    "gr$($categorie_groupe)$($CategorieGroupe):(OI)(CI)(M)"
    }
else 
{
    New-Item -Path "\\S1\C$\_S1_INFO\$Domaine" `
    -ItemType directory
    icacls.exe \\S1\C$\_S1_INFO\$Domaine /grant  `
                     "gr$($categorie_groupe)$($CategorieGroupe):(OI)(CI)(F)"


    #On partage le dossier----------------------------------------------------
New-SMBShare -Name "$($Domaine)$" `
             -Path "C:\_S1_INFO\$Domaine" `
             -FullAccess "Tout le monde" `
             -FolderEnumerationMode AccessBased `
             -CachingMode none `
             -CIMSession "S1"
}

#On leur assigne leur autorisations à leurs dossiers personnels---------------
icacls.exe \\S1\_S1_PERSO$\$Matricule /grant "${Matricule}:(OI)(CI)(M)"


Set-ADUser -Identity $Matricule `
           -HomeDrive "P:" `
           -HomeDirectory "\\S1\_S1_PERSO$\${Matricule}"
          