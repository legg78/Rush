#!/usr/bin/env bash

./run extract -a backoffice -c backoffice_check -r ${CI_BUILD_REF} -n ${CI_BUILD_REF}
./run deploy -a backoffice -n ${CI_BUILD_REF} --with-cleanup -m ci --get-schema
