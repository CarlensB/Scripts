# ==========================================================================# Prénom Nom: Carlens Belony# Date de création: 11 novembre 2022# # But: Création des utilisateurs du domaine ETU1826732.LOCAL et de leurs# dossiers personnels, ainsi que l'assignation des utilisateurs dans leur# groupes respectifs. On crée aussi les dossiers de départements, et on# assigne les autorisations à leur groupes respectifs.# # Ce script doit s’exécuter à partir du S2 et il modifie S1# ==========================================================================#Initialisation des Dossiers Racines------------------------------------------
$chemin = "\\S1\C$\_S1_PERSO"
$chemin2 = "\\S1\C$\_S1_INFO"

#Si ils existent déjà, on les supprime

$resultat = $(try {Get-Item $chemin} catch {$null})            if ($resultat -ne $null)            {                           Remove-Item -LiteralPath $chemin -Force -Recurse            }

$resultat = $(try {Get-Item $chemin2} catch {$null})            if ($resultat -ne $null)            {                           Remove-Item -LiteralPath $chemin2 -Force -Recurse            }


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


#On crée les utilisateurs-----------------------------------------------------$FichierCSV = Import-Csv -Path "Documents\INFORMATIQUE.csv" `                         -Delimiter ";"Foreach ($Ligne in $FichierCSV){  $Matricule    = $Ligne.Matricule  $Nom    = $Ligne.Nom  $Prenom = $Ligne.Prenom  $Adresse = $Ligne.Adresse  $Ville = $Ligne.Ville  $CodePostal = $Ligne.CodePostal  $Tel1 = $Ligne.Tel1  $Tel2 = $Ligne.Tel2  $Tel3 = $Ligne.Tel3  $Domaine = $Ligne.Domaine  $CategorieGroupe = $Ligne.CategorieGroupe  $Type_Employe = $Ligne.Type_Employe  $mdp = ConvertTo-SecureString -AsPlainText "AAAaaa111" -Force;    if ($Matricule % 10000 -eq 0)    {        $categorie_groupe = "GEST";    }    else     {        $categorie_groupe = "EMP";    }  $resultat = $(try {Get-ADUser $Matricule} catch {$null})            if ($resultat -ne $null)            {                           Remove-ADUser $Matricule -Confirm:$false               }New-ADUser -Name $Matricule `            -GivenName $Prenom `            -SurName $Nom `            -DisplayName "$Prenom $Nom" `            -Description "$categorie travaillant dans $nomGr" `            -AccountPassword $mdp `            -PasswordNeverExpires $true `            -Enabled $true ` -Path "OU=$Type_Employe,OU=$Domaine,OU=INFORMATIQUE,DC=ETU1826732,DC=local" `            -OfficePhone $Tel1 `            -OtherAttributes @{'otherTelephone'=$Tel2, $Tel3;                                'c'="CA"; 'co'= "canada"; 'countryCode'=124} `            -streetAddress $Adresse `            -postalCode $CodePostal `            -City $Ville `            -UserPrincipalName $Matricule             #On le mets dans leurs groupes respectifs-------------------------------------     $groupes = "gr$($categorie_groupe)$($CategorieGroupe)", "$Type_Employe"                 Add-ADPrincipalGroupMembership -Identity $Matricule `                            -MemberOf $groupes#On crée leurs dossiers personnels--------------------------------------------
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
          }clsWrite-Host "Le script est terminé!"