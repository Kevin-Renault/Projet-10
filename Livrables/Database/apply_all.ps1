# apply_all.ps1
# Apply the SQL files in the correct order using psql (Windows PowerShell).
# Usage: .\apply_all.ps1 -Database "mydb" -User "postgres" -Host "localhost" -Port 5432
param(
    [string]$Database = "mydb",
    [string]$User = "postgres",
    [string]$Host = "localhost",
    [int]$Port = 5432
)

$files = @(
    '00_extensions_and_settings.sql',
    '01_types_enums.sql',
    '01_acriss_vehicle.sql',
    '02_auth_schema.sql',
    '03_core_domain.sql',
    '04_chat.sql',
    '05_triggers_and_functions.sql',
    '06_indexes_constraints.sql',
    '07_reference_data.sql'
)

foreach ($f in $files) {
    Write-Host "Applying $f ..."
    & psql -h $Host -p $Port -U $User -d $Database -f $f
    if ($LASTEXITCODE -ne 0) { Write-Error "psql failed on $f"; break }
}

Write-Host "Done."
