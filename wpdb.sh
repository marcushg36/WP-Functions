#!/bin/bash
# Description: This function reads the database credentials from the wp-config.php file located in the CWD.
# With these credentials, you are able to import/export the database(s) from MySQL/MariaDB.
# Flags for the command:
# -i) wpdb -i [FILENAME] - This imports the specified database file.
# -x) wpdb -x 		 - This will provide a database export in the CWD (Naming Structure: ${DB_NAME}_${TODAYSDATE}.sql)
# -r) wpdb -r 		 - This will recursively export databases for every WordPress install that it finds from the CWD.
# --reset) wpdb --reset	 - This will clear out all tables in the database.
# Author: Marcus Hancock-Gaillard

function wpdb() {
	while [ $# -gt 0 ]; do
		case "$1" in
			-i|--import)
				sqlfile=$2
				if [[ -f wp-config.php ]]; then
					wpconn=( $(awk -F "'" "/^define\( ?'DB_[NUPH]/{print \$4}" wp-config.php) )
					DB_NAME=${wpconn[0]}
					DB_USER=${wpconn[1]}
					DB_PASSWORD=${wpconn[2]}
					DB_HOST=${wpconn[3]}
					echo "Importing ${sqlfile} To $dbname"
					mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${sqlfile}
					if [[ $? -eq 0 ]]; then
						echo "Import Successful"
						echo -e "${GREEN}${BLINK}Filename${UNBLINK}${SET}: ${sqlfile}"
					else
						echo -e "${RED}${BLINK}MySQL${UNBLINK}${SET}: Import Error"
					fi
				else
					echo -e "${RED}${BLINK}Issue${UNBLINK}${SET}: No WordPress Config File"
				fi
				break
			;;
			-x|--export)
				if [[ -f wp-config.php ]]; then
					wpconn=( $(awk -F "'" "/^define\( ?'DB_[NUPH]/{print \$4}" wp-config.php) )
					DB_NAME=${wpconn[0]}
					DB_USER=${wpconn[1]}
					DB_PASSWORD=${wpconn[2]}
					DB_HOST=${wpconn[3]}
					echo "Dumping ${DB_NAME}"
					mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > ${DB_NAME}_${today}.sql
					if [[ $? -eq 0 ]]; then
						chmod 600 ${DB_NAME}_${today}.sql
						echo "Dump Successful"
						echo -e "${GREEN}${BLINK}File${UNBLINK}${SET}: ${DB_NAME}_${today}.sql"
					else
						echo -e "${RED}${BLINK}MySQL${UNBLINK}${SET}: Export Error"
					fi
				else
					echo -e "${RED}${BLINK}Issue${UNBLINK}${SET}: No WordPress Config File"
				fi
				break
			;;
			-r)
				for cfg in $(find . -type f -name "wp-config.php")
					do
						DIR=`echo $cfg | sed 's,wp-config.php,,'`
						wpconn=( $(awk -F "'" '/DB_[NUPH]/{print $4}' $cfg) )
						DB_NAME=${wpconn[0]}
						DB_USER=${wpconn[1]}
						DB_PASSWORD=${wpconn[2]}
						DB_HOST=${wpconn[3]}
						echo "Dumping ${DB_NAME}"
						mysqldump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > ${DIR}${DB_NAME}_${today}.sql
						if [[ $? -eq 0 ]]; then
							chmod 600 ${DIR}${DB_NAME}_${today}.sql
							echo "Dump Successful"
							echo -e "${GREEN}${BLINK}File${UNBLINK}${SET}: ${DIR}${DB_NAME}_${today}.sql"
						else
							echo -e "${RED}${BLINK}MySQL${UNBLINK}${SET}: Export Error"
						fi
					done
				break
			;;
			--reset)
				if [[ -f wp-config.php ]]; then
					wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
					if [[ $2 == '-y' ]]; then
						php ./wp-cli.phar db reset --yes
					else
						php ./wp-cli.phar db reset
					fi
					rm -f wp-cli.phar
				else
					echo -e "${RED}${BLINK}Issue${UNBLINK}${SET}: No WordPress Config File"
				fi
				break
			;;
		esac
	done
}
