# WinScope 11 native module
[pscustomobject]@{
    Id                = 479
    Name              = 'Reliability Monitor Failure Records'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent Win32_ReliabilityRecords with failure-oriented sources/events.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $cutoff=(Get-Date).AddDays(-30)
            $records=@(Get-CimInstance -Namespace root\cimv2 -ClassName Win32_ReliabilityRecords -ErrorAction Stop | Where-Object {$_.TimeGenerated -ge $cutoff} | Sort-Object TimeGenerated -Descending | Select-Object -First 100)
            if($records.Count -eq 0) {
                & $Context.NewFinding 'Reliability' 'Reliability records' 'NoData' 'No reliability records were returned for the last 30 days.' 'Reliability history availability varies by system configuration.' $null
            } else {
                foreach($r in $records) {
                    & $Context.NewFinding 'Reliability' ([string]$r.SourceName) 'Info' ("Time={0}; EventId={1}; Product={2}; Message={3}" -f $r.TimeGenerated,$r.EventIdentifier,$r.ProductName,$r.Message) 'Use repeated records/trends rather than isolated entries when diagnosing reliability.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'Reliability' 'Reliability records' 'Unavailable' $_.Exception.Message 'Reliability WMI records could not be read.' $null
        }
    }
}
