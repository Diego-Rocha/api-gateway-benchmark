#!/bin/sh

#add hosts
if [ ! $(grep gateway.docker /etc/hosts) ]; then
    echo "${MAIN_HOST} gateway.docker" >> /etc/hosts
fi

#clean results folder
rm -rf ./*

_run(){
    local NAME="${1}"
    local URL="${2}"
    local RPS="${3}"
    local TIME="5s"

    title_out="Benching ${NAME} - ${URL} using ${RPS}rps during ${TIME}"
    echo $title_out

    echo "GET ${URL}" | vegeta attack -name="${NAME}.${RPS}rps" -rate="${RPS}/s" -duration=${TIME} | vegeta report -type=json > "${NAME}.${RPS}rps".json

    results_out=$(cat "${NAME}.${RPS}rps".json | jq '{ throughput: (.throughput | round | tostring + "rps"),success_rate: (.success * 100 | floor | tostring + "%"), errors: .errors }')
    echo $results_out

    echo -e "---\n${title_out}\n${results_out}\n" >> results.log
    echo '---'
    sleep 5
}
run_raw(){
    local NAME="${1}"
    local URL="${2}"
    local RPS="${3}"
    set -- $REQS_MAP
    while [ -n "$1" ]; do
        _run "${NAME}" "${URL}" "${1}";
        shift
    done;
}

run(){
    local NAME="${1}"
    local URL="${2}"
    set -- $API_MAP
    while [ -n "$1" ]; do
        local API="${1}"
        local NEW_NAME="${NAME}_${API}"
        local NEW_URL=$(echo "${URL}" | sed "s/{api}/${API/&/\&}/g")
        run_raw "${NEW_NAME}" "${NEW_URL}" "${RPS}";
        shift
    done;
}

# run
. /endpoints.sh