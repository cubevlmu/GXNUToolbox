param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path
)

$file = Get-Item -LiteralPath $Path -ErrorAction Stop
$hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256

Write-Output ("size: {0}" -f $file.Length)
Write-Output ('sha256: "{0}"' -f $hash.Hash.ToLowerInvariant())
