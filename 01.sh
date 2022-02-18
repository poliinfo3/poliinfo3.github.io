#!/bin/bash

set -xeu

export LC_ALL=C.UTF-8

test -d poliinfo3.net || wget -m -np https://poliinfo3.net/ || true
cd poliinfo3.net
wget -P control-panel/wp-content/plugins https://downloads.wordpress.org/plugin/pdf-embedder.4.6.4.zip
wget -P control-panel/wp-content/plugins https://downloads.wordpress.org/plugin/bogo.3.5.3.zip
wget -P control-panel/wp-content/plugins https://downloads.wordpress.org/plugin/highlighting-code-block.1.5.5.zip
wget -P control-panel/wp-content/plugins https://downloads.wordpress.org/plugin/vk-all-in-one-expansion-unit.9.70.2.0.zip
wget -P control-panel/wp-content/themes https://downloads.wordpress.org/theme/lightning.14.6.2.zip

wget https://poliinfo3.net/favicon.ico
wget -P dashboard https://poliinfo3.net/dashboard/subtasks.json
wget -P dashboard https://poliinfo3.net/dashboard/leader_board.json
wget -P dashboard/css https://poliinfo3.net/dashboard/css/chunk-vendors.aa83a625.css
wget -P dashboard/js https://poliinfo3.net/dashboard/js/chunk-vendors.eb1bb00e.js
wget -P dashboard/js https://poliinfo3.net/dashboard/js/app.765cae55.js

rm -r robots.txt dashboard/js/app.0cd7f1e0.js dashboard/js/chunk-vendors.7c5372d4.js dashboard/css/chunk-vendors.e8d23ed4.css

yes no | source <(find control-panel -name '*\?*' | perl -ne 'chomp; $s = $d = $_; $d =~ s#\?.*$##; printf qq(mv -i %s %s\n), quotemeta($s), quotemeta($d);')
find control-panel -name '*\?*' -print0 | xargs -0 rm

diff -qr en/fact-verification fact-verification
diff -qr en/qa-alignment qa-alignment
diff -qr en/question-answering question-answering
rm -r en/fact-verification en/qa-alignment en/question-answering
ln -s ../fact-verification ../qa-alignment ../question-answering en/

find . -name \*.html -type f -print0 | xargs -0 perl -w -0 -pi.orig \
  -e 'sub r { my $r = $_[0]; $r =~ s#\b(?:https:)?//poliinfo3.net(?=/)##g; return $r } ' \
  -e 's#\r\n#\n#g; ' \
  -e 's#\s*<link rel="alternate"[^>]*>##g; ' \
  -e 's#(<(?:a\b|img\b|script\b|link rel=["\x27]stylesheet["\x27]|link rel="shortcut icon"|h3\b)[^>]+\b(?:href|src|id)=)(["\x27])(?:https:)?//poliinfo3.net(/[^"\x27<>]*\2)#$1$2$3#g; ' \
  -e 's#(<img\b[^>]*\bsrcset=)(["\x27])([^"\x27<>]*)(\2)#$1.$2.r($3).$4#eg; ' \
  -e 's#(url\()(["\x27]?)([^"\x27<>]*)(\2\))#$1.$2.r($3).$4#eg; ' \
  -e 's#(var pdfemb_trans = \{"worker_src":")https:\\/\\/poliinfo3.net(\\/[^"]+","cmap_url":")https:\\/\\/poliinfo3.net(\\/[^"]+")#$1$2$3#g; ' \
  -e 's#(var vkExOpt = \{"ajax_url":")https:\\/\\/poliinfo3.net(\\/[^"]+")#$1$2#g; ' \
  -e 's#</?(ss3-force-full-width|ss3-loader)\b[^>]*>##g; ' \
  -e 's#(?<=\Q/dashboard/js/app.\E)0cd7f1e0(?=\Q.js\E)#765cae55#g; ' \
  -e 's#(?<=\Q/dashboard/js/chunk-vendors.\E)7c5372d4(?=\Q.js\E)#eb1bb00e#g; ' \
  -e 's#(?<=\Q/dashboard/css/chunk-vendors.\E)e8d23ed4(?=\Q.css\E)#aa83a625#g; ' \
;
perl -pi.orig \
  -e 's#(?<=\Q"link": "\E)\Qhttps://poliinfo3.net\E(?=/)##g; ' \
  dashboard/subtasks.json

find . -name \*.html -type f -print0 | egrep -zv '^\.\/(control-panel|dashboard)' | xargs -0 tidy -utf8 -i -w 0 -m || true
find . -name \*.orig -print0 | xargs -0 rm

egrep -r 'poliinfo3.*net' . || true

cd control-panel/wp-content/plugins
unzip -qo pdf-embedder.4.6.4.zip
unzip -qo bogo.3.5.3.zip
unzip -qo highlighting-code-block.1.5.5.zip
unzip -qo vk-all-in-one-expansion-unit.9.70.2.0.zip
rm -f pdf-embedder.4.6.4.zip bogo.3.5.3.zip highlighting-code-block.1.5.5.zip vk-all-in-one-expansion-unit.9.70.2.0.zip
cd ../themes
unzip -qo lightning.14.6.2.zip
rm -f lightning.14.6.2.zip

exit
