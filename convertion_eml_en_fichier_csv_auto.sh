#!/bin/sh

#Pour générer le fichier eml, il faut l’ouvrir dans le navigateur dans une nouvelle fenêtre puis le sauvegarder avec un nom sans espace.

# Si pas d'arguments alors on donne l'aide
if test $# -eq 0; then
	echo "Aide"
	echo "Arguments : à mettre"
	echo "1 - Nom du fichier eml"
#	echo "2 - Nom du fichier Temporaire"
#	echo "3 - datetimestamp au format aaaammjj"
#	echo "2 - Nom du fichier destination Définitif"
exit 1
fi

# Nom du fichier temporaire pour remplacer l’argument 2
TEMPO="/root/temporaire.txt"

# La date du jour pour remplacer l’argument 3
DDJ=$(date -I)

# Nom du fichier destination pour remplacer l’argument 4
RAPPORT="/root/Res.txt"

#On prend le fichier en argument 1 puis
#On supprime de Received à Comptes clients : sed '/Received/,/Comptes clients : /d'
#On supprime de Ceci est un email automatique jusqu’à la fin : sed '/Ceci est un email automatique,/,$ d'
#On remplace retour à la ligne et tiret par virgule : sed -z 's/.\n    - /,/g'
#On remplace machine(s) par virgule : sed 's/machine(s)//g'
#On remplace en succès par virgule : sed 's/ en succès/,/g'
#On remplace les espaces par virgule : sed 's/ /,/g'
#On remplace les anti slash par virgule : sed 's/\//,/g'
#On supprime les lignes vides : sed -e '/^$/d'
#On ajoute en début de ligne l’argument $3 pour différencier les analyses
#On sauvegarde dans le fichier passé en argument $2

sed '/Received/,/Comptes clients : /d' $1 | sed '/Ceci est un email automatique,/,$ d' | sed -z 's/.\n    - /,/g' | sed 's/machine(s)//g' | sed 's/ en succès/,/g' | sed 's/ /,/g'| sed 's/\//,/g' | sed -e '/^[[:space:]]*$/d' | sed 's/^/'$DDJ',/'  > $TEMPO

#On supprime le fichier en argument 4
if [ -d "$RAPPORT" ];then
	echo "Le Fichier existe ! Vidage !";
	rm $RAPPORT
	rm $TEMPO
else
	echo "Le Fichier n'existe pas ! Création !";
	touch $RAPPORT
	touch $TEMPO
fi

echo Date,CT,NB_PC_OK,NB_PC_TOT,NOM_AGENT,NB_JOB_OK,NB_JOB_TOT,Notes > $RAPPORT

#Maintenant on va lire le fichier de destination pour trouver les CT qui ont plus de 1 serveur
while read ligne;
do
#echo $ligne
#	echo $ligne | cut -d',' -f1
# On récupère les éventuels serveurs
CHAMP1=`echo $ligne | cut -d',' -f1,2,3,4`
SRV1=`echo $ligne | cut -d',' -f7,8,9,10,11`
SRV2=`echo $ligne | cut -d',' -f12,13,14,15,16`
SRV3=`echo $ligne | cut -d',' -f17,18,19,20,21`
SRV4=`echo $ligne | cut -d',' -f22,23,24,25,26`
SRV5=`echo $ligne | cut -d',' -f27,28,29,30,31`
NBPC=`echo $ligne | cut -d',' -f4`
#Si il y a un serveur1 on écrit les données de la CT et du serveur1
if [ $NBPC -gt 0 ]; then
    echo $CHAMP1,$SRV1 >> $RAPPORT
#	echo $CHAMP1,$SRV1
fi
#Si il y a un serveur2 on écrit les données de la CT et du serveur2
if [ $NBPC -gt 1 ]; then
    echo $CHAMP1,$SRV2 >> $RAPPORT
#        echo $CHAMP1,$SRV2
fi
#Si il y a un serveur3 on écrit les données de la CT et du serveur3
if [ $NBPC -gt 2 ]; then
    echo $CHAMP1,$SRV3 >> $RAPPORT
fi
#Si il y a un serveur4 on écrit les données de la CT et du serveur4
if [ $NBPC -gt 3 ]; then
    echo $CHAMP1,$SRV4 >> $RAPPORT
fi
#Si il y a un serveur5 on écrit les données de la CT et du serveur5
if [ $NBPC -gt 4 ]; then
    echo $CHAMP1,$SRV5 >> $RAPPORT
fi
done < $TEMPO

exit 0
