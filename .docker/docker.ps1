$ErrorActionPreference = 'stop'

# Import-Module PSYaml

$options = @(
  [System.Management.Automation.Host.ChoiceDescription]::new('&No', 'No')
  [System.Management.Automation.Host.ChoiceDescription]::new('&Yes', 'Yes')
)
function Invoke-DockerUp {
  Import-EnvFile {
    Write-Host "Starting up containers for ${env:PROJECT_NAME}..."
    docker-compose up -d --remove-orphans
  }
}

function Invoke-DockerStop {
  Import-EnvFile {
    Write-Host "Stopping up containers for ${env:PROJECT_NAME}..."
    docker-compose stop
  }
}

function Invoke-DockerRm {
  Import-EnvFile {
    $confirm = $host.ui.PromptForChoice("Removing containers and volumes for ${env:PROJECT_NAME}. Are you sure you want to continue?", "", $options, 0)
    if ($confirm) {
      docker-compose down -v
    }
  }
}

function Invoke-DockerDown {
  Import-EnvFile {
    $confirm = $host.ui.PromptForChoice("Removing containers for ${env:PROJECT_NAME}. Are you sure you want to continue?", "", $options, 0)
    if ($confirm) {
      docker-compose down
    }
  }
}

function Invoke-DockerLs {
  Import-EnvFile {
    docker ps -a --filter name="${env:PROJECT_NAME}*"
  }
}

function Invoke-DockerSh {
  Import-EnvFile {
    docker exec -ti $(docker ps --filter name="${env:PROJECT_NAME}_php" --format "{{ .ID }}") sh
  }
}

function Invoke-DockerLogs {
  Import-EnvFile {
    docker-compose logs -f
  }
}

function Import-EnvFile([scriptblock] $block) {
  $files = Get-ChildItem *.env

  $variables = @{}

  # Load in all environment variables from the .env file.
  foreach($file in $files) {
    $lines = Get-Content $file
    foreach($line in $lines) {
      if ($line -and !$line.StartsWith("#")) {
        # Split by equals
        $parts = $line.Split("=")
        if ($parts.Length -eq 2) {
          $name = $parts[0].Trim()
          $value = $parts[1].Trim()

          # Cache the original value
          if(!$variables.ContainsKey($name)) {
            $variables[$name] = [Environment]::GetEnvironmentVariable($name)
          }

          # Temporarily set the environment variable
          [Environment]::SetEnvironmentVariable($name, $value)

        }
      }
    }
  }

  # Invoke the scriptblock
  & $block

  # Reset all environment variables after the block has run.
  foreach($key in $variables.Keys) {
    [Environment]::SetEnvironmentVariable($key, $variables[$key])
  }
}

# function Add-Site {
#   param(
#     [Parameter(Mandatory=$true)]
#     [string]
#     $name
#   )

#   if (!$name) {
#     throw "Name is required."
#   }

#   if (! (Test-Path "$PSScriptRoot\..\$name")) {
#     mkdir "$PSScriptRoot\..\$name";
#   }

#   if (! (Test-Path "$PSScriptRoot\..\$name\docker-compose.yml")) {
#     Copy-Item "$PSScriptRoot\docker-compose-template.yml" "$PSScriptRoot\..\$name\docker-compose.yml"
#   }

#   if (! (Test-Path "$PSScriptRoot\..\$name\docker.ps1")) {
#     Copy-Item "$PSScriptRoot\docker.template.ps1" "$PSScriptRoot\..\$name\docker.ps1"
#   }

#   if (! (Test-Path "$PSScriptRoot\..\$name\.env")) {
#     $env_template = Get-Content "$PSScriptRoot\template.env" -Raw
#     $env_template = $env_template.Replace('${SITE_NAME}', $name).Replace('${BASE_URL}', "$name.localhost");
#     $env_template | Out-File "$PSScriptRoot\..\$name\.env" -Encoding utf8
#   }

#   # Read the root file and update the site networks
#   $yaml = Get-Content "$PSScriptRoot\..\docker-compose.yml" -Raw
#   $config = ConvertFrom-Yaml $yaml

#   # Add a network that matches the new container
#   $config.networks[$name] = @{ 'external' = @{ 'name' = "${name}_default" } }
#   # Add network to traefik proxy
#   $config.services.traefik.networks += $name
#   $config.services.db.networks += $name
#   $config.services.mailhog.networks += $name

#   $yaml = ConvertToYaml $config
#   $yaml | Out-File "$PSScriptRoot\..\docker-compose.yml" -Encoding utf8
# }
# function Rebuild-Networks {
#   $directories = Get-ChildItem -Directory "$PSScriptRoot\.." | Where-Object { !$_.Name.StartsWith(".") }
#   $yaml = Get-Content "$PSScriptRoot\..\docker-compose.yml" -Raw
#   $config = ConvertFrom-Yaml $yaml

#   foreach($dir in $directories) {
#     $name = $dir.Name
#     if (!$config.networks[$name]) {
#       $config.networks[$name] = @{ 'external' = @{ 'name' = "${name}_default" } }
#       $config.services.traefik.networks += $name
#       $config.services.db.networks += $name
#       $config.services.mailhog.networks += $name
#     }
#   }

#   # Restart the container before making the changes
#   & docker-compose down
#   $yaml = ConvertToYaml $config
#   $yaml | Out-File "$PSScriptRoot\..\docker-compose.yml" -Encoding utf8
#   & docker-compose up -d
# }

# function ConvertToYaml ($obj) {
#   # The default PSYaml serializer does not serialize well.
#   $yaml = ConvertTo-Yaml $obj
#   #return $yaml

#   # Get rid of the \r characters
#   # Skip the unnecessary "---" line
#   # Fix the indent and remove the space from the end of each line
#   # Add extra indent for list lines (as they're not indented enough)
#   $yaml.Split("`r", [System.StringSplitOptions]::RemoveEmptyEntries) `
#     | Select-Object -Skip 1 `
#     | ForEach-Object { $_.Substring(3).TrimEnd()  }
#     #| ForEach-Object { if ($_ -match  "^\W.+-") { "  $_" } else { $_ } }
# }

function Invoke-Docker {
  param(
    [string]
    $command,

    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Parameters
  )

  switch($command) {
    'up'    { Invoke-DockerUp @Parameters }
    'stop'  { Invoke-DockerStop @Parameters }
    'down'  { Invoke-Dockerdown @Parameters }
    'rm'    { Invoke-DockerRm @Parameters }
    'ls'    { Invoke-DockerLs @Parameters }
    'sh'    { Invoke-DockerSh @Parameters }
    'logs'  { Invoke-DockerLogs @Parameters }
   # 'add-site' { Add-Site @Parameters }
   # 'rebuild-networks' { Rebuild-Networks @Parameters }
   # 'test' {
   #   $yaml = Get-Content "$PSScriptRoot\..\docker-compose.yml" -Raw
  #$config = ConvertFrom-Yaml $yaml
#$yaml = ConvertToYaml $config

#$yaml | Out-File "$PSScriptRoot\..\docker-compose.yml" -Encoding utf8

 #   }
    default {
      write-host "The following commands are available: up, stop, rm, ls, sh, logs, rebuild-networks, add-site"
    }
  }
}

