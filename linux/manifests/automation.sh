#!/bin/bash

function replace_image() {
    path=$1
    image=$2
    working_dir=$(dirname $path)

    yq "(.spec.template.spec.containers[] | select(.image == \"MY_NEW_IMAGE\").image) = \"$image\"" $path > $working_dir/new-app.yaml

    show_diff $working_dir/new-app.yaml
}

function show_diff() {
    path=$1

    kubectl diff -f $path
}

function build_image() {
    dockerfile_path=$1
    working_dir=$(dirname $dockerfile_path)
    image=$2

    docker build -t $image -f $dockerfile_path $working_dir
}

function deps_validation() {
    for dep in ${deps[@]}; do
        if [ ! -x "$(which $dep)" ]; then
            echo "$dep is not installed"
            exit 1
        fi
    done
}

function build_and_replace_image() {
    if [ ! -f $dockerfile_path ]; then
        echo "Dockerfile not found"
        exit 1
    fi

    if [ ! -f $manifest_path ]; then
        echo "Manifest not found"
        exit 1
    fi

    tag=$(date +%Y%m%d%H%M%S)

    build_image $dockerfile_path $image_name:$tag
    replace_image $manifest_path $image_name:$tag
}

function interactive_handle() {
    read -p "What is the name of the image you want to build? " image_name
    read -p "Where is the Dockerfile located? " dockerfile_path
    read -p "Where is the manifest that you want to replace the image? " manifest_path
}

function validate_variables() {
    for required_var in ${required_vars[@]}; do
        if [ -z ${!required_var} ]; then
            echo "$required_var is required"
            exit 1
        fi
    done
}

function entrypoint() {
    OPTSTRING=":bih"

    deps=(docker yq kubectl)

    required_vars=(image_name dockerfile_path manifest_path)

    while getopts ${OPTSTRING} opt; do
        case ${opt} in
            i)
            deps_validation
            interactive_handle
            validate_variables
            build_and_replace_image
            ;;
            b)
            deps_validation
            image_name=$2
            dockerfile_path=$3
            manifest_path=$4
            validate_variables
            build_and_replace_image
            ;;
            h)
            # help
            echo "Usage: automation.sh [-b] [-i] [-h]"
            echo "Options:"
            echo "  -b  Background mode, no interactive"
            echo "  -i  Interactive mode"
            echo "  -h  Help"
            echo "Parameters to -b option:"
            echo "  image_name: Name of the image to build"
            echo "  dockerfile_path: Path to the Dockerfile"
            echo "  manifest_path: Path to the Kubernetes manifest"
            exit 0
            ;;
            ?)
            echo "Invalid option: -${OPTARG}."
            exit 1
            ;;
        esac
    done
}

entrypoint $@
 