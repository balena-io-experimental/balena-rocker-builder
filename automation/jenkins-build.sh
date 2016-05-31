#!/bin/bash

set -o errexit
set -o pipefail

for arch in $ARCHS; do
	cp -f Dockerfile.$arch Dockerfile

	rm -rf output
	mkdir -p output
	docker build --no-cache=true -t rocker-builder:$arch .
	docker run --rm --privileged -v `pwd`/output:/output rocker-builder:$arch

	rockerVersion="$(grep -m1 'ENV ROCKER_VERSION ' "Dockerfile" | cut -d' ' -f3)"
	rockerComposeVersion="$(grep -m1 'ENV ROCKER_COMPOSE_VERSION ' "Dockerfile" | cut -d' ' -f3)"
	rockerDir=rocker-linux-$arch-$rockerVersion
	rockerComposeDir=rocker-compose-linux-$arch-$rockerComposeVersion

	printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure

	if [ -f output/rocker ]; then
		mkdir $rockerDir
		cp output/rocker $rockerDir/
		tar -cvzf $rockerDir.tar.gz $rockerDir
		sha256sum $rockerDir.tar.gz > $rockerDir.tar.gz.sha256
		aws s3 cp $rockerDir.tar.gz s3://$BUCKET_NAME/rocker/$rockerVersion/
		aws s3 cp $rockerDir.tar.gz.sha256 s3://$BUCKET_NAME/rocker/$rockerVersion/
		rm -rf $rockerDir*
	fi

	if [ -f output/rocker-compose ]; then
		mkdir $rockerComposeDir
		cp output/rocker-compose $rockerComposeDir/
		tar -cvzf $rockerComposeDir.tar.gz $rockerComposeDir
		sha256sum $rockerComposeDir.tar.gz > $rockerComposeDir.tar.gz.sha256
		aws s3 cp $rockerComposeDir.tar.gz s3://$BUCKET_NAME/rocker-compose/$rockerComposeVersion/
		aws s3 cp $rockerComposeDir.tar.gz.sha256 s3://$BUCKET_NAME/rocker-compose/$rockerComposeVersion/
		rm -rf $rockerComposeDir*
	fi

done
