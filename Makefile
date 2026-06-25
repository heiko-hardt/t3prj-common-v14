include ./.docker/.env

.PHONY: help
help:
	@echo "# Target informations ###############################################################"
	@echo
	@$(MAKE) -s url
	@echo
	@echo "$$ make init     | remove generated content"
	@echo "$$ make clean    | remove generated content"

.PHONY: url
url:
	@echo "Start browsing ..."
	@echo "      web: http://localhost:8080/camino/"

.PHONY: init
init:
	@${MAKE} -s db-cleanup
	@${MAKE} -s fs-cleanup
	@${MAKE} -s fs-prepare
	@${MAKE} -s composer-install
	@${MAKE} -s typo3-setup
	@${MAKE} -s typo3-maintenance
	@${MAKE} -s url

.PHONY: db-auth
db-auth:
	@echo "  - create temporary auth file"
	@echo "[client]\nhost=${DB_HOST}\nport=3306\nuser=${DB_USER}\npassword=${DB_PASSWORD}\nskip-ssl = true\n" > /tmp/.auth.cnf

.PHONY: db-cleanup
db-cleanup:
	@echo "Cleanup database ..."
	@${MAKE} -s db-auth
	@mariadb-dump --defaults-file=/tmp/.auth.cnf --add-drop-table --no-data ${DB_DATABASE} \
		| grep ^DROP \
		| mariadb --defaults-file=/tmp/.auth.cnf --init-command="SET SESSION FOREIGN_KEY_CHECKS=0;" ${DB_DATABASE}

.PHONY: db-import
db-import:
	@echo "Apply database ..."
	@${MAKE} -s db-auth
	@mariadb --defaults-file=/tmp/.auth.cnf --default-character-set=utf8 ${DB_DATABASE} < .resources/sql/mysqldump.sql

.PHONY: db-export
db-export:
	@echo "Dump database ..."
	@${MAKE} -s db-auth
	@mkdir -p .resources/sql
	@mariadb-dump --defaults-file=/tmp/.auth.cnf --default-character-set=utf8 --no-tablespaces ${DB_DATABASE} > .resources/sql/mysqldump.sql

.PHONY: fs-cleanup
fs-cleanup:
	@echo "Cleanup filesystem ..."
	@rm -rf config/system/settings.php config/sites/* .env public var vendor composer.lock

.PHONY: fs-prepare
fs-prepare:
	@echo "Prepare environment ..."
	@rm -f .env && cp .env.dist .env

.PHONY: composer-install 
composer-install:
	@echo "Install composer ..."
	@composer install --optimize-autoloader --classmap-authoritative --no-progress --no-interaction

.PHONY: composer-update 
composer-update:
	@echo "Update composer ..."
	@composer update --optimize-autoloader --classmap-authoritative --no-progress --no-interaction

.PHONY: typo3-maintenance
typo3-maintenance:
	@echo "TYPO3 maintenance ..."
	@vendor/bin/typo3 database:updateschema
	@vendor/bin/typo3 extension:setup
	@vendor/bin/typo3 cache:flush
	@vendor/bin/typo3 cache:warmup

.PHONY: typo3-setup
typo3-setup:
	@echo "setup typo3 ..."
	@vendor/bin/typo3 install:setup \
		--database-driver=pdo_mysql \
		--database-user-name=${DB_USER} \
		--database-user-password="${DB_PASSWORD}" \
		--database-host-name=${DB_HOST} \
		--database-name=${DB_DATABASE} \
		--admin-user-name=${DB_USER} \
		--admin-password="${DB_PASSWORD}" \
		--site-name='TYPO3 Common v.14 LTS' \
		--web-server-config=apache \
		--use-existing-database \
		--no-interaction
