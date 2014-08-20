#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

sleep 5

DATABASE_NAME="setawebsite"
DB_PATH_SQL="/db_product.sql"

if ! mysql -uroot -e "use $DATABASE_NAME"; then
    echo "=> creating database $DATABASE_NAME"
    mysqladmin create $DATABASE_NAME
    
    echo "=> Stopping MySQL Server"
    mysqladmin -uroot shutdown

    sleep 5
    echo "=> Starting MySQL Server"
    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    sleep 5
    echo "   Started with PID $!"
    if mysql -uroot -e "use $DATABASE_NAME"; then
        echo "=> Importing SQL file"
        mysql -uadmin -p$PASS -D$DATABASE_NAME < "$DB_PATH_SQL"
    fi
fi

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

mysqladmin -uroot shutdown