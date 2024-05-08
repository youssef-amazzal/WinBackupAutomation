#! /bin/bash
source ./configuration.sh

if [ $# -eq 0 ]; then 
    echo "Aucun paramètre n'a été passé."
    exit 1
fi

# ************** la vérification de la syntaxe *****************

# Initialiser le flag pour vérifier si les options sont terminées
opt_termine=0
nbr_opt=0

# Boucle pour vérifier la syntaxe des options et des paramètres
for param in "$@"; do
    if [ $opt_termine -eq 0 ]; then
        # Vérifier si le paramètre est une option valide
        case $param in
            -h | -f | -t | -s | -l | -r | -d )
                 nbr_opt=( "$nbr_opt" + 1 )
                ;;
            -* )
                echo "ERREUR-SYNTAXE: L'option $param est inconnue." >&2
                exit 1
                ;;
            * )
		    opt_termine=1
                ;;
        esac
    else
        # Vérifier si les options sont placées avant les paramètres
        case $param in
            -h | -f | -t | -s | -l | -r | -d )
                echo "ERREUR-SYNTAXE: Vous devez mettre les options avant les paramètres." >&2
                exit 1
                ;;
        esac
    fi
done

# ****************** le bloc de traitement ***************

for param in "$@"; do 
    case $param in
        -h ) 
            bash docummentation.sh 
            ;;
        -f ) 
            bash fork.sh 
            ;;
        -t ) 
            bash tread.sh 
            ;;
        -s ) 
            bash subshell.sh 
            ;;
        -l ) 
           # bash log.sh 
           read -p "Tapez le chemin absolu de la nouvelle fichier de journalisation :" FILE_JOURN
            ls "$FILE_JOURN"    #seulement pour le teste
            ;;
        -r ) 
            bash restor.sh 
            ;;
        -d ) 
           # bash destination.sh 
            read -p "Tapez le chemin absolu du nouveau dossier de sauvgarde :" Destination

            ;;
        
    esac

done