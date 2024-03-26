#!/bin/bash

# db_mysql_enter root abc123 ghost
db_mysql_enter() {
    # If you don't specify a database name, you'll enter the MySQL shell without selecting a specific database.
    user=$1
    password=$2
    db=$3
    docker exec -it mysql_db mysql -u$user -p$password $db
}