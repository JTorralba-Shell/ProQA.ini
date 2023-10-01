function Configure
{
    param ([String] $Target_File)

    process
    {
        $Input = New-Object System.IO.StreamReader($Target_File)
        $Tab = [char]9
        
        while (($Target_Machine = $Input.ReadLine()) -ne $null)
        {
            $Target_Machine = $Target_Machine.Trim()
           
            #Modify $Target_Machine 'Medical' 'P'
            #Modify $Target_Machine 'Fire' 'P'
            #Modify $Target_Machine 'Police' 'P'

            #Modify $Target_Machine 'Medical' 'T'
            #Modify $Target_Machine 'Fire' 'T'
            #Modify $Target_Machine 'Police' 'T'

            #Modify $Target_Machine 'Medical' 'S'
            #Modify $Target_Machine 'Fire' 'S'
            #Modify $Target_Machine 'Police' 'S'
        }

        $Input.Close()
    }
}


function Modify
{
    param ([String] $Target_Machine, [String] $Target_Protocol, [String] $EnvironmentX)

    process
    {
        switch ($EnvironmentX.ToUpper())
        {
            'T' {
                $Folder = '_Training'
                }
            'S' {
                $Folder = '_Standalone'
                }
            default {
                $Folder = ''
                }
        }

        Write-Host $Target_Machine $Target_Protocol ' --------------------------------------------------------------------------------'
        Write-Host

        $Target_File_Current = '\\' + $Target_Machine + '\' + 'C$\Program Files\Priority Dispatch\ProQA\' + $Target_Protocol + $Folder + '.New\ProQA.ini'
        $Target_File_New = $Target_File_Current + '.New'
        $Target_File_Old = $Target_File_Current + '.Old'

        Write-Host $Target_File_Current
        Write-Host $Target_File_New
        Write-Host $Target_File_Old

        Write-Host

        if(Test-Path $Target_File_New)
        {
            Remove-Item -Path $Target_File_New -Force
        }

        $Input = New-Object System.IO.StreamReader($Target_File_Current)
        
        while (($Current_Line = $Input.ReadLine()) -ne $null)
        {
            $I = $Current_Line.IndexOf('=')
            if ($I -le 0)
            {
                $I = $Current_Line.Length
                $Key = $Current_Line.SubString(0,$I)
                Add-Content $Target_File_New $Current_Line
                Write-Host $Current_Line
            }
            else
            {
                $Key = $Current_Line.SubString(0,$I)
                $Value = $Current_Line.SubString($I + 1, $Current_Line.Length - $I - 1)
                X $Target_Machine.Substring(0,4) $Target_Protocol $Key $Value $EnvironmentX
            }
        }

        $Input.Close()

        if(Test-Path $Target_File_Old)
        {
            Remove-Item -Path $Target_File_Old
        }

        if(Test-Path $Target_File_Current)
        {
            Rename-Item -Path $Target_File_Current -NewName 'ProQA.ini.Old'
        }

        if(Test-Path $Target_File_New)
        {
            Rename-Item -Path $Target_File_New -NewName 'ProQA.ini'
        }

        Write-Host
        Write-Host
    }
}

function X
{
    param ([String] $Target_Site, [String] $Target_Protocol, [String] $Key, [String] $Value, [String] $EnvironmentX)

    process
    {

        if ($Key -eq 'XLServer')
        {
            $Value = "PARAMOUNT"
        }

        if ($Key -eq 'XLLast')
        {
            $Value = 'PARAMOUNT:9000'
        }

        if ($Key -eq 'XLPrimary')
        {
            $Value = 'PARAMOUNT:9000'
        }

        if ($Key -eq 'XLSecondary')
        {
            $Value = ''
        }

        if ($Key -eq 'XLAlias')
        {
            switch ($EnvironmentX.ToUpper())
            {
                'T' {
                    $Value = 'TRAINING' + '_' + $Target_Protocol.ToUpper() + '03'
                    }
                'S' {
                    $Value = 'TRAINING' + '_' + $Target_Protocol.ToUpper() + '03'
                    }
                default {
                    $Value = $Target_Site + '_' + $Target_Protocol.ToUpper() + '03'
                    }
            }
        }

        if ($Key -eq 'CommMode')
        {
            switch ($EnvironmentX.ToUpper())
            {
                'T' {
                    $Value = '3'
                    }
                'S' {
                    $Value = '0'
                    }
                default {
                    $Value = '3'
                    }
            }
        }

        if ($Key -eq 'CommTcp')
        {
            switch ($Target_Site.ToUpper()) {
                'CSPD' {
                    $Value = '0.0.0.0'
                }
                'AUTH' {
                    $Value = '0.0.0.0'
                }
                default {
                    $Value = '127.0.0.1'
                }
            }
        }

        if ($Key -eq 'CommPort')
        {
            switch ($Target_Protocol.ToUpper()) {
                'MEDICAL' {
                    $Value = '5000'
                }
                'FIRE' {
                    $Value = '5001'
                }
                'POLICE' {
                    $Value = '5002'
                }
                default {
                    $Value = '0000'
                }
            }
        }

        if ($Key -eq 'StationID')
        {
            $Value = $Target_Machine.Substring($Target_Machine.Length - 2)
        }

        if ($Key -eq 'OrbReplyIPAddress')
        {
            $Value = $Target_Machine
        }

        if ($Key -eq 'XLUser')
        {
            $Value = ''
        }

        $Current_Line = $Key + '=' + $Value

        Add-Content $Target_File_New $Current_Line
        Write-Host $Current_Line
    }

}

cls

Start-Transcript -Path "Log_ProQA.ini.txt"

Configure 'Target.txt'

Stop-Transcript




