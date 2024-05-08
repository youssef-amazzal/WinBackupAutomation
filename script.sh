#! /bin/bash
if [ $# -eq 0 ]; then 
    echo "Aucun paramètre n'a été passé."
    exit 1
fi

# ************** la vérification de la syntaxe *****************

# Initialiser le flag pour vérifier si les options sont terminées
opt_termine=0

# Boucle pour vérifier la syntaxe des options et des paramètres
for param in "$@"; do
    if [ $opt_termine -eq 0 ]; then
        # Vérifier si le paramètre est une option valide
        case $param in
            -h | -f | -t | -s | -l | -r | -d )
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

echo "Syntaxe correcte : options avant les paramètres."

