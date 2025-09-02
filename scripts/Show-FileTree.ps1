param(
  [Parameter(Position=0)]
  [string]$Path = '.',

  [int]$Depth = 3,

  [switch]$Files,

  [switch]$Hidden,

  [switch]$Size,

  [int]$MaxEntriesPerDir = 200
)

# ANSI colors via PS 7's $PSStyle
$Fg = $PSStyle.Foreground
$Dim = $PSStyle.Formatting.Dim
$Reset = $PSStyle.Reset

# Box drawing characters
$Chars = [ordered]@{
  Tee  = "├──"
  Last = "└──"
  Vert = "│  "
  Gap  = "   "
}

function Get-ItemIcon {
  param([System.IO.FileSystemInfo]$Item)
  if ($Item.PSIsContainer) { return "📁" }
  switch ([System.IO.Path]::GetExtension($Item.Name).ToLower()) {
    '.ps1' { '⚙️' ; break }
    '.psm1' { '🧩' ; break }
    '.json' { '🗒️' ; break }
    '.md' { '📘' ; break }
    '.js' { '🟨' ; break }
    '.ts' { '🟦' ; break }
    '.py' { '🐍' ; break }
    '.go' { '💠' ; break }
    '.cs' { '🧱' ; break }
    '.yml' { '🧾' ; break }
    '.yaml' { '🧾' ; break }
    default { '📄' }
  }
}

function Format-Size {
  param([long]$Bytes)
  if ($Bytes -lt 1kb) { return "$Bytes B" }
  if ($Bytes -lt 1mb) { return "{0:N1} KB" -f ($Bytes/1kb) }
  if ($Bytes -lt 1gb) { return "{0:N1} MB" -f ($Bytes/1mb) }
  return "{0:N1} GB" -f ($Bytes/1gb)
}

function Show-TreeInternal {
  param(
    [string]$Dir,
    [int]$Level,
    [string]$Prefix
  )

  # Get children respecting options
  $items = Get-ChildItem -LiteralPath $Dir -Force:$Hidden -ErrorAction SilentlyContinue |
           Sort-Object @{Expression = { -not $_.PSIsContainer }}, Name

  if ($MaxEntriesPerDir -gt 0 -and $items.Count -gt $MaxEntriesPerDir) {
    $items = $items | Select-Object -First $MaxEntriesPerDir
    $truncated = $true
  } else {
    $truncated = $false
  }

  for ($i = 0; $i -lt $items.Count; $i++) {
    $item = $items[$i]
    if (-not $Files -and -not $item.PSIsContainer) { continue }

    $isLast = ($i -eq $items.Count - 1)
    $branch = if ($isLast) { $Chars.Last } else { $Chars.Tee }

    $icon = Get-ItemIcon $item

    if ($item.PSIsContainer) {
      $nameColored = "$($Fg.Green)$($item.Name)$Reset"
      $line = "$Prefix$branch $icon $nameColored"
      Write-Host $line
      if ($Level -lt $Depth) {
        $nextPrefix = $Prefix + (if ($isLast) { $Chars.Gap } else { $Chars.Vert })
        Show-TreeInternal -Dir $item.FullName -Level ($Level + 1) -Prefix $nextPrefix
      }
    } else {
      $nameColored = "$($Fg.Cyan)$($item.Name)$Reset"
      if ($Size) {
        try { $len = (Get-Item -LiteralPath $item.FullName -ErrorAction Stop).Length } catch { $len = $null }
        $sizeText = if ($len -ne $null) { " $Dim(" + (Format-Size $len) + ")$Reset" } else { '' }
      } else { $sizeText = '' }
      $line = "$Prefix$branch $icon $nameColored$sizeText"
      Write-Host $line
    }
  }

  if ($truncated) {
    Write-Host "$Prefix$($Chars.Tee) $Dim… ($MaxEntriesPerDir)+ more$Reset"
  }
}

$resolved = (Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue)
if (-not $resolved) {
  Write-Error "Path not found: $Path"
  exit 1
}
$resolvedPath = $resolved.Path

# Root line
$rootName = [System.IO.Path]::GetFileName($resolvedPath.TrimEnd('\/'))
if ([string]::IsNullOrWhiteSpace($rootName)) { $rootName = $resolvedPath }

$rootLabel = if ((Get-Item -LiteralPath $resolvedPath).PSIsContainer) { "$($Fg.Green)$rootName$Reset" } else { "$($Fg.Cyan)$rootName$Reset" }
Write-Host "$(Get-ItemIcon (Get-Item -LiteralPath $resolvedPath)) $rootLabel" 

# Begin tree
if ((Get-Item -LiteralPath $resolvedPath).PSIsContainer) {
  Show-TreeInternal -Dir $resolvedPath -Level 1 -Prefix ''
}

