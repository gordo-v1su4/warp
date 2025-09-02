# Warp

A collection of scripts and configuration for working with Warp and PowerShell on Windows.

## Repo goals
- Keep handy PowerShell scripts and utilities organized
- Make it easy to sync from this machine to your GitHub fork
- Prefer safe, non-interactive scripts suitable for terminal automation

## Structure (proposed)
- scripts/ — PowerShell utilities (e.g., file views, cleanup, helpers)
- docs/ — Notes and usage examples

## Getting started
- Clone/fork this repo on GitHub
- Keep your changes on a personal fork (preferred)

## File Browser (Tree) Script
The scripts/Show-FileTree.ps1 script renders a colorful, icon-enhanced tree view.

Quick usage:

- Show current directory up to depth 2 (folders only):
  powershell path=null start=null
  ./scripts/Show-FileTree.ps1 -Depth 2

- Include files and show sizes:
  powershell path=null start=null
  ./scripts/Show-FileTree.ps1 -Files -Size -Depth 3

- Include hidden items and increase per-folder listing cap:
  powershell path=null start=null
  ./scripts/Show-FileTree.ps1 -Hidden -MaxEntriesPerDir 500

Optional pretty icons module:
- This script draws simple emoji icons directly, so it works out of the box.
- For improved console visuals elsewhere, you can install Terminal-Icons and import it in your PowerShell profile.

Install module (one-time):
powershell path=null start=null
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; Install-Module Terminal-Icons -Scope CurrentUser -Force -Confirm:$false

Add to profile (optional):
powershell path=null start=null
if (-not (Get-Module -ListAvailable Terminal-Icons)) { Import-Module Terminal-Icons }

## Notes
- PowerShell 7+ is recommended
- Windows-specific paths are used in examples
