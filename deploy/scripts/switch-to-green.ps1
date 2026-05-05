# Switch traffic to GREEN by rewriting nginx.conf and reloading nginx
$conf = "deploy/nginx.conf"
$text = Get-Content $conf -Raw

# Comment blue, enable green (make sure lines exist in file)
$text = $text -replace 'server api-blue:8080;', '# server api-blue:8080;'
$text = $text -replace '# server api-green:8080;', 'server api-green:8080;'

Set-Content -Encoding UTF8 $conf $text

docker exec api-router nginx -s reload
"Switched traffic to GREEN"
