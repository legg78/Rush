#!/usr/bin/env bash

FROM_VERSION=v`curl http://sv2-web.bt.bpc.in/product/restapi/${product}/release/${RELEASE}/build_type/last/`

echo "**********************************************"
echo "*     Check increment from ${FROM_VERSION}           *"
echo "**********************************************"
echo
echo
./run checkinc -a backoffice -c backoffice_check -r ${FROM_VERSION}:${CI_BUILD_REF} -m ci --get-schema
