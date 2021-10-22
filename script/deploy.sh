#!/usr/bin/env bash
echo "script started - sourabh"
set -ex

if [ -z "$TRAVIS" ]; then
	echo "This script must be executed from Travis only !"
	exit 1
fi
echo "building docker image - start"
docker build -t sgcoreapp .
docker tag sgcoreapp us-central1-docker.pkg.dev/myproject2-328914/sggcr/sgcoreapp:v1
echo "building docker image - start"

echo "getting gcloud sdk"
curl https://sdk.cloud.google.com | bash -s -- --disable-prompts > /dev/null
export PATH=${HOME}/google-cloud-sdk/bin:${PATH}
gcloud  components install kubectl

echo ${GCLOUD_SERVICE_KEY} | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud config set project myproject2-328914
gcloud  config set container/cluster sgdevops
gcloud  config set compute/zone us-central1-c
gcloud container clusters get-credentials sgdevops

docker build -t sgcoreapp .
docker tag sgcoreapp us-central1-docker.pkg.dev/myproject2-328914/sggcr/sgcoreapp:v1
gcloud docker -- push us-central1-docker.pkg.dev/myproject2-328914/sggcr/sgcoreapp:v1

#kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=gcr.io/${PROJECT_ID}/${APP_NAME}:${TRAVIS_COMMIT}
