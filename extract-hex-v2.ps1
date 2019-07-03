param (

	[Parameter(Mandatory=$true)]
	[string] $Log

)

$hexArray=New-Object System.Collections.ArrayList
$hexRegex=[regex]"([0-9a-fA-F]{16,})"

function make-new-object {
  param ( $hex, $ascii )

  $object = New-Object System.Object
  $object | Add-Member -type NoteProperty -name Hex -Value $hex
  $object | Add-Member -type NoteProperty -name Ascii -Value $ascii
  $object
}

function convert-hex2ascii {
  param ( $hex )

  for ($i=0; $i -lt $hex.Length; $i+=2) { 
    $word += [char][int]::Parse($hex.substring($i,2),'HexNumber') 
  }
  #write-host -ForegroundColor Green $hex
  #write-host -ForegroundColor Yellow $word
  if ( !( $([regex]"^\W+$").Match($word).Success ) ) {
    $hexArray.Add($(make-new-object $hex $word)) | Out-Null
  }
}

Get-Content $Log |% {
  $a = $hexRegex.Match($_)
  if ($a.Success) {
    for ($i=1; $i -lt $a.Groups.Count; $i++) {
      convert-hex2ascii $a.Groups[$i].Value
    }
  }
}

$hexArray | Out-GridView
