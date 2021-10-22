#!/usr/bin/env bash
echo "script started - sourabh"
set -ex

if [ -z "$TRAVIS" ]; then
	echo "This script must be executed from Travis only !"
	exit 1
fi
echo "dotnet build"

dotnet publish

echo "building docker image - start"
docker build -t sgcoreapp .
docker tag sgcoreapp gcr.io/myproject2-328914/sgcoreapp
echo "building docker image - start"

echo "getting gcloud sdk"
curl https://sdk.cloud.google.com | bash -s -- --disable-prompts > /dev/null
export PATH=${HOME}/google-cloud-sdk/bin:${PATH}
gcloud --quiet components install kubectl

echo ${GCLOUD_SERVICE_KEY} | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project myproject2-328914
gcloud --quiet config set container/cluster sgdevops
gcloud --quiet config set compute/zone us-central1-c
gcloud --quiet container clusters get-credentials sgdevops


gcloud --quiet docker -- push us-central1-docker.pkg.dev/myproject2-328914/sggcr/sgcoreapp:v1

#kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=gcr.io/${PROJECT_ID}/${APP_NAME}:${TRAVIS_COMMIT}
