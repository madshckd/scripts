#! /bin/bash

# script to fetch current week's 
# one piece schedule if it's on break
# then it displays
# next chapter's release schedule

# dependencies
# curl, sed, pup

# source : https://claystage.com/
DOMAIN="https://claystage.com/"
PAGE="one-piece-chapter-release-schedule-for-"

# current week and year 
WEEK=$( printf "%02d" $(( $(date +%W) + 1 )))
YEAR=$(date +%Y)

# url
URL=$DOMAIN$PAGE$YEAR

# html parser (pup)
# change to valid location
PUP="./pup"

# creating a RESPONSE file
# worked with named pipeline but didn't work out
touch RESPONSE

#pinging site
ping() {
    # connecting to the site and retrieving RESPONSE HTTP CODE
    echo "connecting ... ( $URL )"
    response=$(curl --silent --head $URL | head -n 1 | cut -d " " -f 2)
    sleep 3

    # proceeding further only if HTTP status is 200
    if [[ $response -eq 200 ]]; then
        # printing success message
        echo "[ok] Valid and working site"
        echo -e "\ngetting response...\n"
        # calling a function to get response
        getResponse $WEEK
    else
        # printing error message
        echo -e "[x] Invalid site\nAborted"
    fi
}

# getting response and displaying results
getResponse() {
    # getting response
    curl --silent --max-time 10 $URL | $PUP ':parent-of(:contains("'"Week $1"'"))' \
        | sed 's/<[^>]*>//g; s/<\/[^>]*>//g' | grep -v '^\s*$' > RESPONSE

    # getting status string from RESPONSE 
    STATUS=$(head -n 2 RESPONSE | tail -n 1 | sed 's/^[[:space:]]*//')

    # depending on status string printing output
    case $STATUS in 
        
        # for break week, looking for next chapter
        "Oda Break" | "WSJ Break")
            echo "There's no chapter release scheduled for this week, try reading previous chapters"
            sleep 2
            echo -e "looking for next chapter release schedule...\n"
            getResponse $( printf "%02d" $(( $1 + 1 )))
            ;;

        # displaying chapter details
        *)
            echo "CHAPTER $STATUS"
            echo "SCAN RELEASE DATE :: $(head -n 3 RESPONSE | tail -n 1)"
            echo "OFFICIAL RELEASE DATE :: $(tail -n 1 RESPONSE)"
            ;;
    esac

    # removing named pipeline
    rm RESPONSE
}

# init
ping

# (0^0)y
