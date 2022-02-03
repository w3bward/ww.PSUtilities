<#	
	.SYNOPSIS
		Generates a random password
	.DESCRIPTION
		Generates a random password, original code courtesy of Simon Wahlin 
		http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
	.PARAMETER MinPasswordLength
		Specifies minimum password length
	.PARAMETER MaxPasswordLength
		Specifies maximum password length
	.PARAMETER PasswordLength
		Specifies a fixed password length
	.PARAMETER InputStrings
		Specifies an array of strings, each string is considered a character group.
		At least one character from each group will be used.
	.PARAMETER FirstChar
		A string representing a character group from which the first character will be selected.
		Useful in cases when the first character must be alphanumeric.
	.PARAMETER Count
		The number of passwords to generate.
	.EXAMPLE
		PS C:\> New-MMRandomPassword 
		k#lzbR64

		Generates a random password of 8 characters in length
	.EXAMPLE
		PS C:\> New-MMRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 5
		Tse$9cdvXZhQ
		Vb1Uk!!DuzM
		TjM!3bxM
		6$Eom3xy!AR
		b@bB5AyR3hoz

		Generates 5 passwords varying in length from 8 to 12 characters.
	.EXAMPLE
		PS C:\> New-MMRandomPassword -PasswordLength 20
		gc7gq$0MZwKb3!IwrtSp

		Generates a single password of 20 characters in length.
#>

function New-RandomPassword {
    [CmdletBinding(DefaultParameterSetName = 'FixedLength', ConfirmImpact = 'None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory = $false,
            ParameterSetName = 'RandomLength')]
        [ValidateScript({ $_ -gt 0 })]
        [Alias('Min')]
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory = $false,
            ParameterSetName = 'RandomLength')]
        [ValidateScript({
                if ($_ -ge $MinPasswordLength) { $true }
                else { Throw 'Max value cannot be lesser than min value.' }
            })]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,
        
        # Specifies a fixed password length
        [Parameter(Mandatory = $false,
            ParameterSetName = 'FixedLength')]
        [ValidateRange(1, 2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '0123456789', '@$!#'),
        
        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String]$FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1, 2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed {
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For ($iteration = 1; $iteration -le $Count; $iteration++) {
            $Password = @{ }
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings
			
            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object { [Char[]]$_ }
			
            # Set password length
            if ($PSCmdlet.ParameterSetName -eq 'RandomLength') {
                if ($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }
			
            # If FirstChar is defined, randomize first char in password from that string.
            if ($PSBoundParameters.ContainsKey('FirstChar')) {
                $Password.Add(0, $FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach ($Group in $CharGroups) {
                if ($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)) {
                        $Index = Get-Seed
                    }
                    $Password.Add($Index, $Group[((Get-Seed) % $Group.Count)])
                }
            }
			
            # Fill out with chars from $AllChars
            for ($i = $Password.Count; $i -lt $PasswordLength; $i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)) {
                    $Index = Get-Seed
                }
                $Password.Add($Index, $AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}