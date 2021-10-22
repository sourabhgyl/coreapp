#!/usr/bin/env bash
echo "script started - sourabh"
set -ex

if [ -z "$TRAVIS" ]; then
	echo "This script must be executed from Travis only !"
	exit 1
fi

curl https://sdk.cloud.google.com | bash -s -- --disable-prompts > /dev/null
export PATH=${HOME}/google-cloud-sdk/bin:${PATH}
gcloud --quiet components install kubectl

echo ${GCLOUD_SERVICE_KEY} | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project ${PROJECT_ID}
gcloud --quiet config set container/cluster ${CLUSTER_NAME}
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}

docker build -t ${APP_NAME} .
docker tag ${APP_NAME} gcr.io/${PROJECT_ID}/${APP_NAME}:${TRAVIS_COMMIT}
gcloud docker -- push gcr.io/${PROJECT_ID}/${APP_NAME}:${TRAVIS_COMMIT}

#kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=gcr.io/${PROJECT_ID}/${APP_NAME}:${TRAVIS_COMMIT}
