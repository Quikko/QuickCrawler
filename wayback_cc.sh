#!/bin/bash

##Work-Flow:
## 1.First fetch all the javascript URLS from Burp and save them in a list
## 2.Enumerate on subdomains and provide the list towards this script
## 3. waybackurls will be called on each of the subdomain
wayback(){
    if [ -z "$1" ] || [ -z "$2" ]
        then
            echo "[!] Usage: ./wayback.sh [subdomain-list][domain]"
        exit 1;
    fi
    echo -e "[+] Reading the subdomains line per line, given to waybackurls tool"
    while IFS='' read -r line || [[ -n "$line" ]]; do
        ./waybackurls "$line" | sort | uniq >> wayback_all_urls.txt
    done < "$1" 
    echo -e "[+] Wayback done"
}
#Make Binary from cc.py so we do not edit the path whole time.
##Work-Flow:
## 1. Give a certain domain to cc.py
## 2. cc.py will do the rest --> No js files in the output.
## 3. TO-DO: regex for secret,api keys, token, jwt,  usernames, passwords, ids, ... Everything that could be sensitive and send over GET.
cc_py(){
    if [ -z "$1" ] || [ -z "$2" ]
        then
            echo "[!] Usage: ./wayback.sh [subdomain-list][domain]"
        exit 1;
    fi
    echo -e "[+] Getting all information from http://index.commoncrawl.org"
        python ./cc.py/cc.py "$2" -o temp_cc_py.txt
        #Remove duplicates + sort
        cat temp_cc_py.txt | sort | uniq >> cc_py.txt
        rm temp_cc_py.txt
    echo -e "[+] Done with commoncrawl.org"
}
##Work-Flow:
## 1.Fetch all the JavaScript files from wayback list.
## 2.See if they are still valid or not.

js_analyzer(){
    if [ ! -f wayback_all_urls.txt ]
        then
            echo "[!] Usage: The wayback file cannot be found. Make sure it's under the right directory"
            exit 1;
        fi
    echo -e "[+] Fetching all URLs with javascript files from wayback results"
        while IFS='' read -r line || [[ -n "$line" ]]; do
            #Fetch JS files.
            if echo -e "\t[-] Found: $line" | grep "\.js"; then
                curl "$line" -w 'Status:%{http_code}\t Size:%{size_download}\t %{url_effective}\n' -o /dev/null -sk
            fi
        done < wayback_all_urls.txt
}

wayback "$1" "$2"
cc_py "$1" "$2"
js_analyzer
