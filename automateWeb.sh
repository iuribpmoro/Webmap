#!/bin/bash

subsList=$1
aliveSubsFilename="aliveSubs.txt"

httpx -list $subsList -silent -o $aliveSubsFilename
gowitness file -f $aliveSubsFilename

for sub in $(cat $aliveSubsFilename);do
        parsedSub=$(echo $sub | cut -d "/" -f3)
        mkdir $parsedSub

        katana -u $sub -kf all -fs fqdn -o $parsedSub/katana-tmp.txt
        waybackurls $sub | grep $sub > $parsedSub/wayback-tmp.txt
        touch $parsedSub/finalUrls.txt

        cat $parsedSub/katana-tmp.txt | anew $parsedSub/finalUrls.txt
        cat $parsedSub/wayback-tmp.txt | anew $parsedSub/finalUrls.txt
        cat $parsedSub/finalUrls.txt | grep -Ev "jpg|jpeg|png|svg|ico|mp4" > $parsedSubs/filteredUrls.txt

        gowitness file -f $parsedSub/filteredUrls.txt
done
