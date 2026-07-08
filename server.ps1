$port = 8777
$root = 'C:\Claude\Sessions'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = [System.Uri]::UnescapeDataString($ctx.Request.Url.LocalPath).TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = 'graphic-studio.html' }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      switch ($ext) {
        '.html' { $ctx.Response.ContentType = 'text/html; charset=utf-8' }
        '.js'   { $ctx.Response.ContentType = 'text/javascript' }
        '.css'  { $ctx.Response.ContentType = 'text/css' }
        '.json' { $ctx.Response.ContentType = 'application/json' }
        '.svg'  { $ctx.Response.ContentType = 'image/svg+xml' }
        default { $ctx.Response.ContentType = 'application/octet-stream' }
      }
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  } catch { }
}
