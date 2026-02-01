# ============================================================
# CREATE CLEAN FOLDER STRUCTURE FOR 16-fabric-sales-analytics
# ============================================================

$root = "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\16-fabric-sales-analytics"

# --- Core folders ---
New-Item -ItemType Directory -Force -Path "$root\config" | Out-Null
New-Item -ItemType Directory -Force -Path "$root\data"   | Out-Null
New-Item -ItemType Directory -Force -Path "$root\docs"   | Out-Null
New-Item -ItemType Directory -Force -Path "$root\notebooks" | Out-Null

# --- Bronze layer folders ---
New-Item -ItemType Directory -Force -Path "$root\data\bronze" | Out-Null
New-Item -ItemType Directory -Force -Path "$root\docs\bronze" | Out-Null
New-Item -ItemType Directory -Force -Path "$root\notebooks\bronze" | Out-Null

# --- Future layers (empty placeholders, optional) ---
New-Item -ItemType Directory -Force -Path "$root\data\silver" | Out-Null
New-Item -ItemType Directory -Force -Path "$root\data\gold"   | Out-Null

# --- ZTemp staging folder ---
New-Item -ItemType Directory -Force -Path "$root\ZTemp" | Out-Null

Write-Host "Clean folder structure created."