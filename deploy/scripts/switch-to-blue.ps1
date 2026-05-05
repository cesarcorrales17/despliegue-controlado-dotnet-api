# Switch traffic to BLUE by rewriting nginx.conf and reloading nginx
$conf = "deploy/nginx.conf"
$text = Get-Content $conf -Raw
$text = $text -replace 'server api-blue:8080;', 'server api-blue:8080;'
$text = $text -replace 'server api-green:8080;', '# server api-green:8080;'
if ($text -notmatch 'server api-blue:8080;') { throw "Missing blue server line" }
Set-Content -Encoding UTF8 $conf $text

docker exec api-router nginx -s reload
"Switched traffic to BLUE"
