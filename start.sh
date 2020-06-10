#!/bin/bash
if [ -z "$REDIRECTS" ]; then
	echo "Redirects variable not set (REDIRECTS)"
	exit 1
fi

# Default to 80
LISTEN="80"
# Listen to PORT variable given on Cloud Run Context
if [ ! -z "$PORT" ]; then
	LISTEN="$PORT"
fi

# Specify custom log format
cat <<EOF > /etc/nginx/conf.d/default.conf
log_format redirects '[\$time_local] \$request_method \$scheme://\$host\$request_uri';
EOF

while IFS=',' read -ra redirects; do
	for pair in "${redirects[@]}"; do
		origin=${pair%=*}
		destination=${pair#*=}

		# Add http if not set
		if ! [[ $destination =~ ^https?:// ]]; then
			destination="http://$destination"
		fi

		# Add trailing slash
		if [[ ${destination:length-1:1} != "/" ]]; then
			destination="$destination/"
		fi

		cat <<-EOF >> /etc/nginx/conf.d/default.conf
		server {
			listen ${LISTEN};
			server_name $origin;
			access_log /var/log/nginx/access.log redirects;

			rewrite ^/(.*)\$ ${destination}\$1 permanent;
		}
		EOF
	done
done <<< "$REDIRECTS"

echo "Listening on port $LISTEN..."

exec nginx -g "daemon off;"
