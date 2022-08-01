#https://www.hanselman.com/blog/adding-predictive-intellisense-to-my-windows-terminal-powershell-prompt-with-psreadline
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows


## Shorcuts for our commands
Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
   -BriefDescription BuildCurrentDirectory `
   -LongDescription "dotnet Build the current directory" `
   -ScriptBlock {
   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build")
   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key Ctrl+Shift+t `
   -BriefDescription TestCurrentDirectory `
   -LongDescription "dotnet Test the current directory" `
   -ScriptBlock {
   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet test")
   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


Import-Module Terminal-Icons
Import-Module posh-git
oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/jandedobbeleer.omp.json | Invoke-Expression



<#
.Description
autostart docker (not needed in W11)
https://stackoverflow.com/a/65814529/1219811
#>
function Start-Docker() {
   wsl.exe -u root -e sh -c "service docker status || service docker start"
}

Start-Docker

function Set-Shutdown($h) {
   $t = $h * 60 * 60
   $dte = Get-Date
   $dte = $dte.AddSeconds($t)
   $c = "Shutdown at $dte"
   shutdown /s /t $t /c $c && $c
}

function Get-ShutdownTime() {
   $dte = Get-Date
   return NEW-TIMESPAN –Start $dte  –End   (Get-Uptime -Since).AddHours($h) 
}

function Urlencode {
   param (
      [Parameter(
         Mandatory = $true, 
         ValueFromPipeline = $true)
      ]
      [String]
      $urlToEncode
   ) 
   process {
      return [System.Web.HttpUtility]::UrlEncode($urlToEncode) 
   }
}

function Urldecode {
   param (
      [Parameter(
         Mandatory = $true, 
         ValueFromPipeline = $true)
      ]
      [String]$urlToDecode
   )

   process {
      return [System.Web.HttpUtility]::UrlDecode($urlToDecode)
   }
}

function New-Password {
   param (
      [Parameter(Mandatory)]
      [int] $length
   )
   #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
   $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
   $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
   $bytes = New-Object byte[]($length)

   $rng.GetBytes($bytes)

   $result = New-Object char[]($length)

   for ($i = 0 ; $i -lt $length ; $i++) {
      $result[$i] = $charSet[$bytes[$i] % $charSet.Length]
   }

   return (-join $result)
}


function ConvertFrom-AzureAppSettings {
   [OutputType('hashtable')]
   param (
      [Parameter(
         Mandatory = $true, 
         ValueFromPipeline = $true)
      ]
      [string]$object
   )
   process {
      $hash = @{}
         (ConvertFrom-Json $object) | ForEach-Object {
         $hash[$_.name] = $_.value
      }
      return $hash   
   }
}

function ConvertTo-DotEnv {
   param (
      [Parameter(
         Mandatory = $true, 
         ValueFromPipeline = $true)
      ]
      [Hashtable]$object
   )

   process {
      return $object.Keys | % { $_ + '=' + $object.Item($_) }
   }
}
