#! /bin/bash
source ./setupEnv.sh

if [ $# -eq 0 ]; then 
    log_message 'ERROR' "${ERRORS[$OBLIGATORY_PARAMS]}" 'ERROR'
    exit 1
fi

# ************** la vérification de la syntaxe *****************

# Initialiser le flag pour vérifier si les options sont terminées
opt_termine=0
nbr_opt=0

# Boucle pour vérifier la syntaxe des options et des paramètres
for ((i=1; i<=$#; i++)); do 
    param=${!i}
    if [ $opt_termine -eq 0 ]; then
        # Vérifier si le paramètre est une option valide
        case $param in
            -h | -f | -t | -s | -l | -r | -d )
                 nbr_opt=( "$nbr_opt" + 1 )
                ;;
            -* )
                log_message 'ERROR' "ERREUR-SYNTAXE: L'option $param est inconnue." 'ERROR'
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
                log_message 'ERROR' "ERREUR-SYNTAXE: Vous devez mettre les options avant les paramètres." 'ERROR'
                exit 1
                ;;
        esac
    fi
done

# ****************** le bloc de traitement ***************

for ((i=1; i<=$#; i++)); do 
    param=${!i}
    case $param in
        -h ) 
            display_help
            ;;
        -f ) 
            bash fork.sh 
            ;;
        -t ) 
            bash threads.sh 
            ;;
        -s ) 
            bash subshell.sh 
            ;;
        -l ) 
            i=$((i+1))
            LOGFILE=${!i}
            echo "LOGFILE=\"$LOGFILE\"" > $USER_SETTINGS_FILE
            ;;
        -r ) 
            rm $USER_SETTINGS_FILE
            ;;
        -d ) 
            read -p "Tapez le chemin absolu du nouveau dossier de sauvgarde :" Destination
            ;;
         * )
            if [ -e "$param" ]; then 
                 zip -r "$Destination/$param.zip" "$param"
            else
                log_message 'ERROR' "Le fichier ou le dossier '$param' n'existe pas." 'ERROR'
            fi
           ;;
    esac
done