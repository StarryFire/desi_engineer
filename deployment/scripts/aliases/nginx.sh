#!/bin/bash

get_nginx_workers() {
    dc_cmd $1 sh -c "'
    apt update && 
    apt install procps
    '"
    dc_exec $1 ps aux | grep nginx | grep worker
}