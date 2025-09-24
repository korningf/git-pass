
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
    gpg --decrypt "$File.gpg" 2>$null
}



# Set secret
Set-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin" -Secret $Secret -Param "name=value"

# Get secret
$Secret = Get-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin"

echo $Secret

