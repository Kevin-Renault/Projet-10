# apply_all.ps1
# Apply the SQL files in the correct order using psql (Windows PowerShell).
# Usage: .\apply_all.ps1 -Database "mydb" -User "postgres" -Host "localhost" -Port 5432
[CmdletBinding()]
param(
    [string]$Database = "mydb",
    [string]$User = "postgres",
    [string]$Host = "localhost",
    [int]$Port = 5432
)

$ErrorActionPreference = 'Stop'

$files = @(
    '00_extensions_and_settings.sql',
    '02_types_enums.sql',
    '01_acriss_vehicle.sql',
    '03_auth_schema.sql',
    '04_core_domain.sql',
    '05_chat.sql',
    '06_triggers_and_functions.sql',
    '07_indexes_constraints.sql',
    '08_reference_data.sql',
    '09_person_seed.sql'
)

foreach ($file in $files) {
    $path = Join-Path $PSScriptRoot $file

    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "SQL file not found: $path"
    }

    Write-Host "Applying $file ..."
    & psql -v ON_ERROR_STOP=1 -h $Host -p $Port -U $User -d $Database -f $path
    if ($LASTEXITCODE -ne 0) {
        throw "psql failed on $file (exit code $LASTEXITCODE)"
    }
}

Write-Host "Database initialization completed successfully."
