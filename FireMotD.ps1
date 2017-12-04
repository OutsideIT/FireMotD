Function Get-FireMotD
{
  Param
  (
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)][ValidateNotNullOrEmpty()][string[]]$ComputerName,
    [Parameter(Position=1)][System.Management.Automation.CredentialAttribute()][pscredential]$Credential,
    [Parameter(Position=2)][System.ConsoleColor]$Color = 'Cyan',
    [Parameter(Position=3)][switch]$RandomColor,
    [Parameter(Position=4)][switch]$ShowTimer
  )
  
  Begin
  {
    If ($ShowTimer.IsPresent)
    {
      $MeasureProcessTime = [System.Diagnostics.Stopwatch]::StartNew()
    }
    If ($RandomColor.IsPresent)
    {
      $Colors = ([Enum]::GetValues([System.ConsoleColor])) | Where-Object { $_ -ne $Host.UI.RawUI.BackgroundColor -and $_ -ne $Host.UI.RawUI.ForegroundColor }
      $Color = $Colors[(Get-Random -Maximum $Colors.Count)]
    }
    # Define a scriptblock that retrieves all required information
    $ScriptBlock = {
      $IP = ([System.Net.DNS]::GetHostAddresses($env:COMPUTERNAME) | Where-Object {$_.AddressFamily -eq "InterNetwork" -and $_.IPAddressToString -notmatch '^(127|169)'} | Select-Object -ExpandProperty IPAddressToString) -join ', '
      $OS = Get-WmiObject -Class Win32_OperatingSystem -Impersonation Impersonate
      $Disk = Get-PSDrive -Name "$($OS.SystemDrive -replace ':', '')" -PSProvider FileSystem
      $Powershell = $PSVersionTable.PSVersion
      $Processes = (Get-Process).Count
      $Processor = Get-WmiObject -Class Win32_Processor -Property Name,LoadPercentage,NumberOfCores -Impersonation Impersonate
      $Sessions = @(quser.exe).Count - 1
      $System = Get-WmiObject -Class Win32_ComputerSystem -Impersonation Impersonate
      $Uptime = (([DateTime]::Now)-([System.Management.ManagementDateTimeconverter]::ToDateTime($OS.LastBootUpTime)))
            
      [PSCustomObject]@{
        Host = "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
        User = "$($env:USERNAME)"
        Disk = $Disk
        IP = $IP
        OS = $OS
        Powershell = $Powershell
        Processes = $Processes
        Processor = $Processor
        Sessions = $Sessions
        System = $System
        Uptime = $Uptime
      }
    }
  }
  
  Process
  {
    
    $CommandParams = @{
      ScriptBlock = $ScriptBlock
      ErrorAction = 'Stop'
    }
    
    If ($ComputerName)
    {
      $SessionParams = @{
        ComputerName = $ComputerName
        ErrorAction = 'Stop'
      }
      
      If ($Credential) { $SessionParams.Add('Credential', $Credential) }
      
      Try { $Session = New-PSSession @SessionParams }
      Catch
      {
        If (((Get-WmiObject -Class Win32_Service -Filter "name='WinRM'" @SessionParams).StartService()).ReturnValue -ne 0)
        {
          Throw $_.Exception.Message
        }
        Else
        {
          Try { $Session = New-PSSession @SessionParams }
          Catch
          {
            Throw $_.Exception.Message
            Break
          }
        }
      }
    }
    Else { $Session = $null }
    
    If ($Session) { $CommandParams.Add('Session', $Session) }
    
    Try { $Result = Invoke-Command @CommandParams }
    Catch { Throw $_.Exception.Message }
    Finally { If ($Session) { Remove-PSSession $Session } }
  }
  
  End
  {
    Write-Host                                    ''
    Write-Host -ForegroundColor $Color            "                   $($Result.Host)"
    Write-Host                                    ''
    Write-Host -ForegroundColor $Color -NoNewline '              IP = '
    Write-Host                                    "$($Result.IP)"
    Write-Host -ForegroundColor $Color -NoNewline '         Release = '
    Write-Host                                    "$($Result.OS.Caption) $($Result.OS.CSDVersion)"
    Write-Host -ForegroundColor $Color -NoNewline '          Kernel = '
    Write-Host                                    "NT $($Result.OS.Version) ($($Result.OS.OSArchitecture))"
    Write-Host -ForegroundColor $Color -NoNewline '        Platform = '
    Write-Host                                    "$($Result.System.Manufacturer) $($Result.System.Model) $($Result.System.SystemType)"
    Write-Host -ForegroundColor $Color -NoNewline '          Uptime = '
    Write-Host                                    "$($Result.Uptime.Days) day(s), $($Result.Uptime.Hours):$($Result.Uptime.Minutes):$($Result.Uptime.Seconds)"
    Write-Host -ForegroundColor $Color -NoNewline '       Installed = '
    Write-Host                                    "$(([System.Management.ManagementDateTimeconverter]::ToDateTime($Result.OS.InstallDate)).toString('F'))"
    Write-Host -ForegroundColor $Color -NoNewline '       CPU Usage = '
    Write-Host                                    "$([Math]::Round(($Result.Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average),2))% avg over $($Result.System.NumberOfProcessors) CPU(s) ($(@($Result.Processor)[0].NumberOfCores) core(s) - $($Result.System.NumberOfLogicalProcessors) thread(s))"
    Write-Host -ForegroundColor $Color -NoNewline '             CPU = '
    Write-Host                                    "$(@($Result.Processor).Count) x $(@($Result.Processor)[0].Name)"
    Write-Host -ForegroundColor $Color -NoNewline '          Memory = '
    Write-Host                                    "Free: $([Math]::Round(($Result.OS.FreePhysicalMemory/1MB),2))GB, Used: $(([Math]::Round(($Result.OS.TotalVisibleMemorySize/1MB),2)) - ([Math]::Round(($Result.OS.FreePhysicalMemory/1MB),2)))GB, Total: $([Math]::Round(($Result.OS.TotalVisibleMemorySize/1MB),2))GB"
    Write-Host -ForegroundColor $Color -NoNewline '            SWAP = '
    Write-Host                                    "Free: $([Math]::Round(($Result.OS.FreeVirtualMemory/1MB),2))GB, Used: $(([Math]::Round(($Result.OS.TotalVirtualMemorySize/1MB),2)) - ([Math]::Round(($Result.OS.FreeVirtualMemory/1MB),2)))GB, Total: $([Math]::Round(($Result.OS.TotalVirtualMemorySize/1MB),2))GB"
    Write-Host -ForegroundColor $Color -NoNewline '            Root = '
    Write-Host                                    "Free: $([Math]::Round(($Result.Disk.Free/1GB),2))GB, Used: $([Math]::Round(($Result.Disk.Used/1GB),2))GB, Total: $([Math]::Round(($Result.Disk.Used/1GB) + ($Result.Disk.Free/1GB),2))GB"
    Write-Host -ForegroundColor $Color -NoNewline '        Sessions = '
    Write-Host                                    "$($Result.Sessions) session(s)"
    Write-Host -ForegroundColor $Color -NoNewline '       Processes = '
    Write-Host                                    "$($Result.Processes) running processes of $($Result.OS.MaxNumberOfProcesses) max processes"
    Write-Host -ForegroundColor $Color -NoNewline '      Powershell = '
    Write-Host                                    "$($Result.Powershell.Major).$($Result.Powershell.Minor) (Build: $($Result.Powershell.Build) - Rev: $($Result.Powershell.Revision))"
    If ($ShowTimer.IsPresent)
    {
      Write-Host -ForegroundColor $Color          "                   Processed in $($MeasureProcessTime.Stop(); [Math]::Truncate($MeasureProcessTime.Elapsed.TotalMilliseconds))ms"
    }
    Write-Host                                    ''
  }
}