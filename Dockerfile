FROM tutum/lamp:latest
MAINTAINER Kevin Seta <kien6336@setacinq.com.vn>

# Download latest version of Setaweb into /app
RUN rm -fr /app && git clone --depth=1 https://github.com/allready4v/sachsongngu.git /app

# Configure Wordpress to connect to local DB
ADD wp-config.php /app/wp-config.php
RUN chmod 644 /app/wp-config.php

# Modify permissions to allow plugin upload
RUN chmod -R 777 /app/wp-content

# Add database setup script
ADD db_product.sql /db_product.sql
RUN chmod 777 /db_product.sql
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

ENV MYSQL_PASS setawebsite

EXPOSE 80 3306
CMD ["/run.sh"]

