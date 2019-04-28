function npp($path)
{
	& "C:\Program Files (x86)\Notepad++\notepad++.exe" $path
}

function processZeroPage
{
  $lines = Get-Content ".\inc\zeroPage.asm" | ? { $_.Contains(".rs ") };
  $total = 0;
  
  $targetFile = "zeroPage.txt"
  if ([System.IO.File]::Exists($targetFile))
  {
    [System.IO.File]::Delete($targetFile)
  }

  $order = New-Object System.Collections.Specialized.OrderedDictionary
  
  foreach ($line in $lines)
  {
    $matches = $line | select-string "([^\s]+)\s+\.rs\s+(\d+)" -AllMatches
    
    $var = $matches.Matches.Groups[1].Value
    $size = $matches.Matches.Groups[2].Value -as [int]
    
    $order.Add($var, "{0:X2}" -f $total)
    
    $total += $size    
  }
  
  $order > $targetFile
}

function GetAsmFile
{
	$array = Get-ChildItem .
	$file = $null
	foreach ($item in $array)
	{
		if ($item.Extension -eq ".asm")
		{
			if ($file -eq $null)
			{
				$file = $item.Name
			}
			else
			{
				Write-Error "More than one .asm file"
				return $null
			}
		}
	}
	
	if ($file -eq $null)
	{
		Write-Error "No .asm files found"
	}
	
	return $file
}

function AsmToNes($file)
{
	return $file.Substring(0, $file.Length - 4) + ".nes"
}

function Assemble
{
	$file = GetAsmFile
	if ($file -eq $null)
	{
		return
	}
	
	$rom = AsmToNes $file
	if (Test-Path $rom)
	{
		del $rom
	}
	
	& "C:\users\tomas\Documents\NES\Tools\NESASM\nesasm3.exe" $file
  
  processZeroPage
}

function Run([Switch]$NoAssembly)
{
	if (-not $NoAssembly)
	{
		Assemble
	}

	$file = GetAsmFile
	if ($file -eq $null)
	{
		return
	}
	
	$rom = AsmToNes $file
	if (Test-Path $rom)
	{
		& "C:\Users\tomas\Documents\NES\Tools\FCEUXDSP\fceuxdsp.exe" $rom
	}
	else
	{
		Write-Error "ROM missing; assembly failed?"
	}
}