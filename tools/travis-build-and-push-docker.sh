#!/bin/bash

make rel

MIM_TAR_FULL_NAME=mongooseim-$TRAVIS_BRANCH.$TRAVIS_OTP_RELEASE.$(lsb_release -is | tr "A-Z" "a-z").$(lsb_release -rs).$(uname -m).tar.bz2

MONGOOSE_TGZ=mongooseim.tar.gz

tar -cjh --transform='s,rel/mongooseim,mongooseim-${$TRAVIS_BRANCH},S' -f ${MIM_TAR_FULL_NAME} rel/mongooseim
tar czh --transform='s,rel/mongooseim,mongooseim,S' -f $MONGOOSE_TGZ rel/mongooseim

export BUILDS=`pwd`
export MEMBER_TGZ=mongooseim.tar.gz


MIN_DOCKER_REPO=github.com/michalwski/mongooseim-docker-minimal.git
git clone https://${MIN_DOCKER_REPO}
cd mongooseim-docker-minimal
cp ../${MONGOOSE_TGZ} member

git add member/${MEMBER_TGZ}
git config user.name "MongooseIM"
git config user.email "mongoose-im@erlang-solutions.com"
git commit -m "mongooseim.tar.gz for esl/MongooseIM@${TRAVIS_COMMIT}"
git push https://${GITHUB_TOKEN}@${MIN_DOCKER_REPO} master:${TRAVIS_BRANCH}

cd ../

git clone https://github.com/michalwski/mongooseim-docker.git
cd mongooseim-docker

DOCKERHUB_TAG=${TRAVIS_BRANCH}

if [ ${TRAVIS_PULL_REQUEST} != 'false' ]; then
    DOCKERHUB_TAG="PR-${TRAVIS_PULL_REQUEST}"
elif [ ${TRAVIS_BRANCH} == 'master' ]; then
    DOCKERHUB_TAG="latest";
fi

cp ../${MONGOOSE_TGZ} member

docker build -f Dockerfile.member -t mongooseim .

docker login -e=${DOCKERHUB_EMAIL} -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASS}

docker tag mongooseim ${DOCKERHUB_USER}/mongooseim:${DOCKERHUB_TAG}

docker push ${DOCKERHUB_USER}/mongooseim:${DOCKERHUB_TAG}

