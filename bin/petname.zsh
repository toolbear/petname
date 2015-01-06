#!/usr/bin/env zsh

set -e
set -x

local us=$(basename $0)
local server=$1

if ((!$+server)); then
  cat <<EOF >&2
usage: $us SERVER

  $us example.dev:443
  $us https://example.dev/
  $us https://example.dev:443/
EOF
  exit 1
fi

server=$(ruby -r uri -e 's=ARGV[0]; u = URI.parse(s); u.host && u.port and puts "#{u.host}:#{u.port}" or puts s =~ /:\d+$/ ? s : "#{s}:443"' $server)

openssl s_client -connect $server </dev/null |tee \
  >(openssl x509 -noout -sha1 -subject -nameopt utf8,dn_rev,lname,sep_multiline |sed -n 's/^  *//;/^commonName=/p') \
  >(openssl x509 -noout -sha1 -modulus |cut -d= -f2 |openssl sha1) #|openssl sha1
