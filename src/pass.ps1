
# Powershell Pass command (POSIX Password-Store)



# using namespace System.Management.Automation
# using namespace Microsoft.PowerShell.SecretManagement

# class PasswordStoreVault : ISecretVault {
#     [string]$VaultName = "PasswordStore"

#     PasswordStoreVault([string]$vaultName) {
#         $this.VaultName = $vaultName
#     }

#     [PSObject] GetSecret([string]$name, [Hashtable]$parameters) {
#         $secret = & pass show $name
#         return $secret
#     }

#     void SetSecret([string]$name, [PSObject]$secret, [Hashtable]$parameters) {
#         $secret | & pass insert -m $name
#     }

#     void RemoveSecret([string]$name, [Hashtable]$parameters) {
#         & pass rm -f $name
#     }

#     [SecretInformation[]] GetSecretInfo([Hashtable]$parameters) {
#         $entries = & pass list
#         return $entries | ForEach-Object {
#             [SecretInformation]@{
#                 Name = $_
#                 Type = [SecretType]::String
#             }
#         }
#     }

#     void UnlockVault([Hashtable]$parameters) {
#         # Unlock logic if needed
#     }
# }

# Register-SecretVault -Name "PasswordStore" -ModuleName "PasswordStoreVault" -VaultParameters @{ }


# TODO: adapt this to your DNS Domain
$DOMAIN = "$env:USERDNSDOMAIN"
$DOMAIN = "$env:ViewClient_LoggedOn_FQDN"

# TODO: adapt this to your Email
$USER = "$env:USERNAME"
$EMAIL = "$USER@$DOMAIN"
$STORE = "$env:USERPROFILE\.password-store"


# List Secret
function List-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Path
    )
    $File = "$STORE\$Path"

    if ( [System.IO.Directory]::Exists("$File")) {
       echo ".\$Path"
       tree /a /f "$File" | tail +4
       return
    }

    if ( [System.IO.File]::Exists("$File.gpg")) {
       echo ".\$Path"
       return
    }

}

# Set Secret
function Set-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Path,
        [string]$Secret,
        [string]$Param
    )
    $File = "$STORE\$Path"

    if ( [System.IO.File]::Exists("$File.gpg")) {
       Write-Output "Secret $File.gpg already exists: Exiting."
       return
    }

    echo "$Secret" > "$File.txt"
    gpg --output "$File.gpg" --encrypt --recipient "$Email" "$File.txt"
    rm -f "$File.txt"
}


# Get Secret
function Get-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Path
    )
    $File = "$STORE\$Path"

    if (-not [System.IO.File]::Exists("$File.gpg")) {
       Write-Output "Secret $File.gpg not found: Exiting."
       return
    }

    $Secret = gpg --decrypt "$File.gpg" 2>$null

    echo $Secret
    
    return $Secret
}

# Del Secret
function Del-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Path,
        [string]$Secret
    )
    $File = "$STORE\$Path"

    if (! [System.IO.File]::Exists("$File.gpg")) {
       Write-Output "Secret $File.gpg already exists: Exiting."
       return
    }

    rm -f "$File.gpg"
}


# List secret
List-Secret -Store $STORE -Email $EMAIL -Path ""

# List secret
List-Secret -Store $STORE -Email $EMAIL -Path "."

# List secret
List-Secret -Store $STORE -Email $EMAIL -Path "ssh"

# List secret
List-Secret -Store $STORE -Email $EMAIL -Path "windows"

# List secret
List-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin"

# Set secret
Set-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin" -Secret $Secret -Param "name=value"

# Get secret
$Secret = Get-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin"

echo $Secret




# # Example array
# $args = @("first", "second", "third")

# # Shift operation
# $firstArg = $args[0]  # Extract the first element
# $args = $args[1..($args.Length - 1)]  # Keep the rest of the elements

# # Output
# Write-Output "First Argument: $firstArg"
# Write-Output "Remaining Arguments: $args"
