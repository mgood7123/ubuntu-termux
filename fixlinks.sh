if [[ $# < 4 ]]
    then
        echo please pass me a path to the file, the new root, the old root, and the folder relative to the old root
        echo "a 5th argument (file, new, old, rel_old, arg5) will do a dry run, no changes will be made"
        exit
fi

D=0

if [[ $# == 5 ]]
    then
        D=1
fi


R1="$2"
R2="$3"
R3="$4"

S="$(readlink "$1")"
if [[ "$S" == "$R2/$R3/"* ]]
    then
        if [[ $D == 1 ]]
            then
            echo "match $1"
            echo "old link $S"
        fi
        S="$(printf "$S" | sed "s/$(printf "$R2/$R3" | sed "s/\//\\\\\//g")/$(printf "$R1" | sed "s/\//\\\\\//g")/")"
        if [[ $D == 1 ]]
            then
                echo "new link $S"
        fi
        if [[ $D == 0 ]]
            then
                rm "$1"
                ln -s "$S" "$1"
        fi
fi
