param(
    [switch]$DryRun,
    [string]$Message
)

Write-Host ""
Write-Host "==============================================="
Write-Host "   Gulf to Bay Analytics — Git Sync Utility"
Write-Host "==============================================="
Write-Host ""

# ------------------------------------------------------------
# Auto-detect repo root
# ------------------------------------------------------------
$repoRoot = git rev-parse --show-toplevel 2>$null

if (-not $repoRoot) {
    Write-Host "❌ Not inside a Git repository."
    exit 1
}

Write-Host "📁 Repo detected: $repoRoot"
Write-Host ""

# ------------------------------------------------------------
# Pre-push validation
# ------------------------------------------------------------
Write-Host "🔍 Running pre-push validation..."
Write-Host ""

# 1. Check for merge conflicts
$conflicts = git diff --name-only --diff-filter=U
if ($conflicts) {
    Write-Host "❌ Merge conflicts detected:"
    $conflicts | ForEach-Object { Write-Host "   - $_" }
    exit 1
}

# 2. Check for untracked files
$untracked = git ls-files --others --exclude-standard
if ($untracked) {
    Write-Host "⚠️ Untracked files detected:"
    $untracked | ForEach-Object { Write-Host "   - $_" }
    Write-Host ""
}

# 3. Check branch
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "🌿 Current branch: $branch"
Write-Host ""

# ------------------------------------------------------------
# Commit message presets
# ------------------------------------------------------------
if (-not $Message) {

    Write-Host "📝 Select a commit message:"
    Write-Host "1. Update documentation"
    Write-Host "2. Update scripts"
    Write-Host "3. Update SQL assets"
    Write-Host "4. Update Power BI assets"
    Write-Host "5. General update"
    Write-Host "6. Custom message"
    Write-Host ""

    $choice = Read-Host "Enter choice (1-6)"

    switch ($choice) {
        "1" { $Message = "Update documentation" }
        "2" { $Message = "Update scripts" }
        "3" { $Message = "Update SQL assets" }
        "4" { $Message = "Update Power BI assets" }
        "5" { $Message = "General update" }
        "6" { $Message = Read-Host "Enter custom commit message" }
        default { 
            Write-Host "Invalid choice. Using default message."
            $Message = "Update"
        }
    }
}

# ------------------------------------------------------------
# Add timestamp
# ------------------------------------------------------------
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$Message = "$Message — $timestamp"

Write-Host ""
Write-Host "📝 Final commit message:"
Write-Host "   $Message"
Write-Host ""

# ------------------------------------------------------------
# Dry run mode
# ------------------------------------------------------------
if ($DryRun) {
    Write-Host "🔎 Dry run mode enabled — no changes will be made."
    Write-Host ""
    Write-Host "Would run:"
    Write-Host "   git add ."
    Write-Host "   git commit -m `"$Message`""
    Write-Host "   git push"
    exit 0
}

# ------------------------------------------------------------
# Check if there is anything to commit
# ------------------------------------------------------------
$pending = git status --porcelain
if (-not $pending) {
    Write-Host "✔️ No changes to commit."
    exit 0
}

# ------------------------------------------------------------
# Execute Git operations
# ------------------------------------------------------------
Write-Host "📌 Staging changes..."
git add .

Write-Host "📌 Committing..."
git commit -m "$Message"

Write-Host "📌 Pushing..."
git push

Write-Host ""
Write-Host "✅ Sync complete."
Write-Host ""
