function wpht() {
	wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	if [[ -e .htaccess ]]; then
	    cp .htaccess{,-${date +%s)}
	fi
	if [[ -e wp-cli.yml ]]; then
		mv wp-cli.yml{,.BAK}
	fi
	echo -e "apache_modules:\n - mod_rewrite" > wp-cli.yml
	php ./wp-cli.phar rewrite flush --hard
	sleep 1
	rm -f wp-cli.yml wp-cli.phar
	if [[ -e wp-cli.yml.BAK ]]; then
		mv wp-cli.yml{.BAK,}
	fi
}
