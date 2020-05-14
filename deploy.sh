#!/bin/bash

if [ ! -z $1 ]

then
    DCF="docker-compose-$1"
else
    DCF="docker-compose"
fi

if (! docker stats --no-stream ); then
    # On Mac OS this would be the terminal command to launch Docker
    echo "Docker Destop not running! starting ..."
    open /Applications/Docker.app
    while true; do
        read -p "Is Docker klaar? [y/N] " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit 0;;
            * ) exit 0;;
        esac
    done
    if (! docker stats --no-stream ); then
        echo "ongeduldig type!"
        echo "begin maar opnieuw, dan draait docker miscchien inmiddels"
        exit 0
    fi
fi

if [ ! -f ./$DCF.yml ]; then
    echo "$DCF.yml niet gevonden!"
	exit 1
else
	echo "Deploy met $DCF"
fi

while true; do
    read -p "Wil je eerst een build doen? [y/N] " yn
    case $yn in
        [Yy]* ) docker-compose -f $DCF.yml build; break;;
        [Nn]* ) break;;
        * ) break;;
    esac
done

# kubectl get deploy

DEPLOYMENT=$(grep -A3 'x-deployment:' $DCF.yml | tail -n1);
DEPLOYMENT=${DEPLOYMENT//*x-deployment: /}
if [ "$DEPLOYMENT" = "" ]; then
	echo "x-deployment niet ingesteld in $DCF.yml"
	echo "gebruik \"kubectl get deploy\" om juiste waarde te vinden."
	exit 1
fi

# gcloud container images list --repository eu.gcr.io/editoo-development
# gcloud container images list-tags eu.gcr.io/editoo-development/editoo-workers
# gcloud container images describe eu.gcr.io/editoo-development/editoo-workers
echo "Voorbereiden ..."
CONTAINER="$(kubectl describe deploy $DEPLOYMENT)"
CONTAINER="$(echo $CONTAINER | egrep -o 'Containers.*?Image')"
CONTAINER=${CONTAINER:12:(${#CONTAINER}-19)}
PUSHRESULT="$(docker-compose -f $DCF.yml push)"
IMAGENAME="$(echo $PUSHRESULT | egrep -o '\[.*?\]')"
IMAGENAME=${IMAGENAME:1:(${#IMAGENAME}-2)}

SHADIGEST="$(echo $PUSHRESULT | egrep -o '(digest: ).*?( size)')"
SHADIGEST=${SHADIGEST:8:(${#SHADIGEST}-13)}

kubectl set image deployment/$DEPLOYMENT  $CONTAINER=$IMAGENAME@$SHADIGEST
kubectl rollout status deployment/$DEPLOYMENT
kubectl get deploy $DEPLOYMENT
echo "Als er problemen zijn voer dan volgende commando uit:"
echo "kubectl rollout undo deployment $DEPLOYMENT"
echo ""
echo "Om geschiedenis van deployments te ziem:"
echo "kubectl rollout history deployment/$DEPLOYMENT"
exit 0
