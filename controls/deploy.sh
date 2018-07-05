#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID="$1"
export AWS_SECRET_ACCESS_KEY="$2"
export EC2_NAME="nginx-lua"
export EC2_REGION="eu-west-1"
export EC2_AVAILZONE="c"
export EC2_VPCID="vpc-e1e18987"
export EC2_SUBNIP="subnet-0d228601508200f35"
export EC2_OPENPORT="80"
export DOCKER_IMAGE="nood/opsapp"
export DOCKER_CONTAINER_NAME="opsapp"

get_instance_ip() {

    EC2_IP=$(docker-machine ip $EC2_NAME | gawk 'BEGIN { RS = "[ \t\n]"; FS = "." } /^([0-9]+[.]){3}[0-9]+$/ && ! rshift(or(or($1, $2), or($3, $4)), 8) { print ; exit; }')
    echo ${EC2_IP}

}

run_instance() {

set -x

    check_if_ec2_instance_go_away

    echo "Launching EC2 instance"
    docker-machine create \
        --driver amazonec2 \
        --amazonec2-region ${EC2_REGION} \
        --amazonec2-zone ${EC2_AVAILZONE} \
        --amazonec2-vpc-id ${EC2_VPCID} \
        --amazonec2-subnet-id ${EC2_SUBNIP} \
        --amazonec2-open-port ${EC2_OPENPORT} \
        --amazonec2-tags Surname,Ivanov,Firstname,Yehor \
        ${EC2_NAME}

    echo "Waiting until public IP is accessible"
    sleep 10
set +x

}

install_docker_machine() {

    #//TODO define version as variable
    base=https://github.com/docker/machine/releases/download/v0.15.0 && \
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && \
    install /tmp/docker-machine /usr/local/bin/docker-machine

}

release_app() {

    eval $(docker-machine env ${EC2_NAME})
    docker pull ${DOCKER_IMAGE}
    docker stop ${DOCKER_CONTAINER_NAME} || true
    docker rm ${DOCKER_CONTAINER_NAME} || true
    docker run -d -p ${EC2_OPENPORT}:80 --restart=always --name=${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE}
    eval $(docker-machine env -u)

    curl_check

    exit 0

}

curl_check() {

    check_url="http://${EC2_IP}/"
    http_response=$(curl --write-out %{http_code} --silent --output /dev/null ${check_url} )
    echo "Deploy result: ${check_url} : ${http_response}"

}

check_docker_machine_installed() {

    if ! [ -x "$(command -v docker-machine)" ]; then
        echo "docker-machine does not installed on this machine"
        echo "Installing it now"
        install_docker_machine
    fi

}

check_if_secrets_passed() {

    if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY ]]; then
      echo 'One or more variables are undefined'
      exit 1
    fi

}

check_if_ec2_instance_go_away() {

    if [[ $(docker-machine ls | grep -v Timeout ) ]]; then
        echo "You have lost ec2 instance."
        docker-machine rm ${EC2_NAME}
    fi
}

check_if_ec2_launched_and_do_all_things() {

if [[ $(docker-machine ls | grep "${EC2_NAME}" | grep -v Error ) ]]; then
        echo "Nice, instance running: ${EC2_IP}"
        echo "Releasing app now!"
        release_app
else
        echo "I cant see EC2 instance. Running it..."
        run_instance
        release_app
fi

}

#Run scenario
check_if_secrets_passed
check_docker_machine_installed
get_instance_ip
set -x
check_if_ec2_instance_go_away
check_if_ec2_launched_and_do_all_things
set +x
