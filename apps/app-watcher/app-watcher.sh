#!/usr/bin/env bash
set -ex

## watcher dir ##
DIR="/app-watcher"

## Kubernetes Stuff
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

echo "Start watching"
#fswatch -1 --event Created -v -i "${DIR}/*" -0 "${DIR}" | xargs -0 -n 1 -I {} echo "{}"
watcher=($(fswatch -1 --event Created -v -i "${DIR}/*" -0 "${DIR}"))
APP=$(echo ${watcher[0]} | cut -d'/' -f3-)
COMMAND=$(cat ${watcher[0]})

echo "Stop watching... ${COMMAND} will happen in 10s."
sleep 10
echo "APP: ${APP}"
echo "Launched command: ${COMMAND}"

if [[ "$APP" = "filebrowser" ]] && [[ "$COMMAND" = "restart" ]] ; then
	echo "Cant restart filebrowser... exiting"
	rm -f ${watcher} > /dev/null 2>&1
	exit 1
fi

if [[ "$COMMAND" = "restart" ]] ; then
	echo "Restarting app"
	curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X PATCH "${APISERVER}/apis/apps/v1/namespaces/${NAMESPACE}/deployments/tenet-${APP}?fieldManager=kubectl-rollout&pretty=true" \
	--header 'Content-Type: application/strategic-merge-patch+json' \
	--data-raw '{
		"spec": {
			"template": {
				"metadata": {
					"annotations": {
						"kubectl.kubernetes.io/restartedAt": "'$(date +%Y-%M-%dT%H:%M:%S)'"
					}
				}
			}
		}
	}'
elif [[ "$COMMAND" = "reset" ]] ; then
	echo "Resetting app"
else
	echo "ERROR: Unknown command... exiting"
	rm -f ${watcher} > /dev/null 2>&1
	exit 1
fi

# remove file anyways
rm -f ${watcher} > /dev/null 2>&1
exit 0