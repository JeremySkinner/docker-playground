param(
  [string]
  $command
)

function Invoke-DockerUp {
  Import-EnvFile {
    Write-Host "Starting up containers for ${env:PROJECT_NAME}..."
    docker-compose pull --parallel
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
    Write-Host "Removing containers for ${env:PROJECT_NAME}..."
    docker-compose down -v
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

switch($command) {
  'up'    { Invoke-DockerUp $args }
  'stop'  { Invoke-DockerStop $args }
  'rm'    { Invoke-DockerRm $args }
  'ls'    { Invoke-DockerLs $args }
  'sh'    { Invoke-DockerSh $args }
  'logs'  { Invoke-DockerLogs $args }
  default {
    write-host "The following commands are available: up, stop, rm, ls, sh, logs"
  }
}