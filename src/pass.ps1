
#--------------------------------------------------------------------#
#
#                          GIT-Pass
#
# POSIX Pass command (aka Password-Store) for GitBash and PowerShell.
#
#--------------------------------------------------------------------#

#
# Git-Pass is a port of the POSIX pass command (aka password-store),
# for institutional desktops that only allow a limited Gitbash shell.
#
# Pass is a secure Secrets Store aka a Secure Password-Manager or Vault.
# It follows the POSIX design of using simple composable shell commands.
# It is meant for portability and simplicity -it is mostly shell-diven;
# all it needs is a shell with installed SSH, SSL, GPG, Git, and Tree.
#
# Our architecture design seeks simplicity, portability, and consistency.
# Pass gives us a consistent secret manager accross windows, linux, & unix,
# even on corporate or institutional minimal thin-client windows desktops.
# Git-Pass includes our own `pass.ps1` script porting pass to powershell.
#
# There are many secret stores, from Keepass to SOPS and Hashicorp Vault.
# Many are UI based and may use licensed binaries or cloud subscriptions.
# Many are proprietary and store their database as a single opaque vault.
# 
# Pass is free, lightweight, portable, with well audited open-source code.
# It is but a script that calls industry-standard OSS tools: SSL, GPG, Git.
# The encryption uses state of the art crypto via RSA keys and a GPG keys.
# 
# The vault is just a directory tree, into which go our encrypted secrets.
# Thus secret names can be easily located, indexed, globbed, and queried.
# This open directory structure makes it extremely adaptable and flexible.
# 
# The directory can also be a Git repo and can be shared over machines.
# It can also be shared with other users or multiple vaults can be used.
# 
# The secret file format holds a plain text secret on its very first line;
# the rest of the file may contain metadata as name-value parameter pairs.
# 
# You can use it for passwords, secrets, identity credentials, SSH PEM keys.
# They can be invoked or piped in a command-line or pasted to the clipboard.
# Pass has a plethora of extension plugins to integrate with other systems.
#
# The only extension we require is pass-file to encrypt entire files.
# We use this to encrypt SSH private keys and Certifcate private keys.
# Now we could just secure keys with a passphrase - pass simplifies this
# by providing a single interface api to unify all our private secrets
# in a single vault with a single passphrase.
#
# Now because it relies on bare tools, pass can be ported to Powershell,
# which means we can use the same interface for both Bash and Powershell.
# For added portability, we can implement the PowerShel.SecretManagement
# ISecureVault, allowing it to integrate with windows application stacks.
#


#
# For extension plugins, the general design is the path comes last,
# in order to parse and shift subcommands and their option switches;
# that is, the very last non-switch arg should be a store pathname.
#
#
#
# pass                  --> lists all secrets
# pass dir              --> lists dir secrets
# pass name             --> shows secret
# pass --clip name      --> copies secret to clipboard
#
#
# Usage:
# 
#   pass                                        [path] ! 
#   pass [show|get]   [-c|clip]                  path
#   pass [list|ls]                              [dir]
#   pass insert|set   [-f|force] [-m|multiline]  name *
#   pass rm|remove    [-f|force] [-r|recurse]    path *
#   pass mv|move      [-f|force] [-r|recurse]    path *
#   pass cp|copy      [-f|force] [-r|recurse]    path *
#   pass help|usage   
#
#
# File:
#
#   pass file add     file    dir
#   pass file get             dir/name    
#
# (!)
# Pass accepts a convenience shortcut invocation without a command.
# - will show the secret if the path maps a file (named $path.pgp).
# - will list the secrets if if the path masp to a directory name.
#
# (*)
# Pass is very POSIX and uses -f --force and -r --recurse switches,
# allowing to reorganise gpg secrets and their directrory structure;
# -m --multiline reads a multiline secret from stdin (EOD = CTRL-D).
#
#
# (+)
#
# Pass-File stores files in the subdirectory specified by the path:
#
# Add file:                                      (stores files in subdirectory)   
#
#   pass file add ~/.ssh/id_rsa     ssh/id_rsa    ->  ssh/id_rsa/id_rsa.gpg
#   pass file add ~/.ssh/id_rsa.pem ssh/id_rsa    ->  ssh/id_rsa/id_rsa.pem.gpg
#   pass file add ~/.ssh/id_rsa.pub ssh/id_rsa    ->  ssh/id_rsa/id_rsa.pub.gpg
#
# Get file:                                      (specify directory + name)
#
#   pass file get ssh/id_rsa/id_rsa
#   pass show ssh/id_rsa/id_rsa                  (*equivalent for text files)
#
# Note Pass-file works exactly like a reglar 'pass --multiline' call,
# the only difference being it does not prompt to enter the contents.
#
# If the file is text, 'pass show' works just like 'pass file get',
# file contents can be copied to the clipboard using 'pass --clip'.
#
# But if the file is binary, it outputs the raw binary file contents.
# In such case, you should redirect the binary output stream to a file.
#
# Binary file:
#
#    pass file get ssh/id_rsa/id_rsa.der > ~/.ssh/id_rsa.der
#
# Note the binary machine encoding stays the same as its original creation,
# so if you share binary files across machines using git or other means,
# management of encoding is up to you (as it would be without pass or git).
#
# It does not currently allow to copy a binary COM object to clipboard,
# this would be great for images like QR codes (investigate COM images).
#
# Speaking of QR codes, the original pass command supports 'pass ---qrcode' 
# and calls 'qrencode` to generate a QR code for a text secret or password;
# it places it on the XWindows clipboard (so why not the Windows clipboard).
# Now it would be really great to port this to windows, but that requires a
# lot of work.
#


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
        [string]$Name
    )
    $Path = "$STORE\$Name"

    if ( [System.IO.Directory]::Exists("$Path")) {
       echo ".\$Name"
       tree /a /f "$Path" | tail +4
       return
    }

    if ( [System.IO.File]::Exists("$Path.gpg")) {
       echo ".\$Name"
       return
    }

}

# Set Secret
function Set-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Name,
        [string]$Secret,
        [string]$Param
    )
    $Path = "$STORE\$Name"

    if ( [System.IO.File]::Exists("$Path.gpg")) {
       Write-Output "Secret $Path.gpg already exists: Exiting."
       return
    }

    #echo "$Secret" > "$Path.txt"
    #gpg --output "$Path.gpg" --encrypt --recipient "$Email" "$Path.txt"
    #rm -f "$Path.txt"

    $input | gpg --output "$Path.gpg" --encrypt --recipient "$Email"
}


# Get Secret
function Get-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Name
    )
    $Path = "$STORE\$Name"

    if (-not [System.IO.File]::Exists("$Path.gpg")) {
       Write-Output "Secret $Path.gpg not found: Exiting."
       return
    }

    $Secret = gpg --decrypt "$Path.gpg" 2>$null

    echo $Secret
    
    return $Secret
}

# Del Secret
function Del-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$Name,
        [string]$Secret
    )
    $Path = "$STORE\$Name"

    if (! [System.IO.File]::Exists("$Path.gpg")) {
       Write-Output "Secret $Path.gpg already exists: Exiting."
       return
    }

    rm -f "$Path.gpg"
}





# Testors


# hardcoded

function Test-Hardcoded () {
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
    #Set-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin" -Secret $Secret -Param "name=value"

    # Get secret
    $Secret = Get-Secret -Store $STORE -Email $EMAIL -Path "windows\ntlogin"
}


# parametrised

function test-Parametrised () {
    # Set secret
    Set-Secret -Store $STORE -Email $EMAIL -Path "$Name"

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -Path "$Name"

    # Get secret
    $Secret = Get-Secret -Store $STORE -Email $EMAIL -Path "$Name"
}



# # Example array
# $args = @("first", "second", "third")

# # Shift operation
# $firstArg = $args[0]  # Extract the first element
# $args = $args[1..($args.Length - 1)]  # Keep the rest of the elements

# # Output
# Write-Output "First Argument: $firstArg"
# Write-Output "Remaining Arguments: $args"



$Name = ""
$Command = ""
$SubCommand = ""



# Options

# Commands
if ( $args.Count -gt 0) {
    $arg = $args[0]
    
    # basic commmands

    # help
    if ( $arg -eq "help" -or $arg -eq "/?") {
        $Command = "help"

        if (! $args.Count -gt 0) {
            exit "(INVALID): pass file ?"
        }

        $args = $args[1..($args.Length - 1)]

        echo "(TODO) pass file help $args"
        exit
    }

    # show
    elseif ( $arg -eq "show" -or $arg -eq "get") {
        $Command = "show"
        $args = $args[1..($args.Length - 1)]

        echo "(TODO) pass file show $args"
        exit
    }

    # list
    elseif ( $arg -eq "ls" -or $arg -eq "list") {
        $Command = "list"
        $args = $args[1..($args.Length - 1)]

        echo "(TODO) pass file list $args"
        exit
    }

    # insert
    elseif ( $arg -eq "insert" -or $arg -eq "set") {
        $Command = "insert"
        $args = $args[1..($args.Length - 1)]

        echo "(TODO) pass file insert $args"
        exit
    }

    # rm
    elseif ( $arg -eq "rm" -or $arg -eq "remove") {
        $Command = "rm"
        $args = $args[1..($args.Length - 1)]
        
        $Path = $args[0]
        echo "(TODO): pass file cp $args"
        exit
    }

    # mv
    elseif ( $arg -eq "mv" -or $arg -eq "move") {
        $Command = "mv"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file mv $args"
        exit
    }

    # cp
    elseif ( $arg -eq "cp" -or $arg -eq "copy") {
        $Command = "cp"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file cp $args"
        exit
    } 

    # exotic commmands

    # find
    elseif ( $arg -eq "find") {
        $Command = "find"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file find $args"
        exit
    } 
    # grep
    elseif ( $arg -eq "grep") {
        $Command = "grep"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file grep $args"
        exit
    } 
    # edit
    elseif ( $arg -eq "edit") {
        $Command = "edit"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file edit $args"
        exit
    } 


    # git
    elseif ( $arg -eq "git") {
        $Command = "git"
        $args = $args[1..($args.Length - 1)]

        $Path = $args[0]
        echo "(TODO): pass file git $args"
        exit
    } 


    # extension commands

    # file
    elseif ( $arg -eq "file") {
        $Command = "file"
        $args = $args[1..($args.Length - 1)]

        if (! $args.Count -gt 0) {
            exit "(INVALID): pass file ?"
        }
        $Subcommand = $args[0]
        $args = $args[1..($args.Length - 1)]

        if ( $SubCommand -eq "get") {
            $Name = $args[0]
            echo "(TODO): pass file get $args"
            exit
        }

        if ( $SubCommand -eq "set") {

            if (! $args.Count -gt 1) {
                exit "(INVALID): pass file set ? ?"
            }

            $File = $args[0]
            $Name = $args[1]
            echo "(TODO): pass file set $args"
            exit
        }
    }

    echo "(PARSED) $Coomand $SubCommand $args"
    exit
}


# switches
foreach ($arg in $args) {
  if ( $arg -eq "-f" -or $arg -eq "--force") {
      $Force = "-f"
      $args = $args[1..($args.Length - 1)]
  }
  if ( $arg -eq "-r" -or $arg -eq "--recurse") {
      $Recurse = "-r"
      $args = $args[1..($args.Length - 1)]
  }
  elseif ( $arg -eq "-m" -or $arg -eq "--multiline") {
      $Multiline = "-m"
      $args = $args[1..($args.Length - 1)]      
  }
  elseif ( $arg -eq "-c" -or $arg -eq "--clip") {
      $Clip = "-c"
      $args = $args[1..($args.Length - 1)]      
  }
}
