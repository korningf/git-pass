
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

# Pass is a secure Secrets Store aka a Secure Password-Manager or Vault.
# It follows the POSIX design of using simple composable shell commands.
# It is meant for portability and simplicity -it is mostly shell-diven;
# all it needs is a shell with installed SSH, SSL, GPG, Git, and Tree.

# Our architecture design seeks simplicity, portability, and consistency.
# Pass gives us a consistent secret manager accross windows, linux, & unix,
# even on corporate or institutional minimal thin-client windows desktops.
# Git-Pass includes our own `pass.ps1` script porting pass to powershell.

# There are many secret stores, from Keepass to SOPS and Hashicorp Vault.
# Many are UI based and may use licensed binaries or cloud subscriptions.
# Many are proprietary and store their database as a single opaque vault.

# Pass is different. By design it is open and transparent in its workings.

# Pass is free, lightweight, portable, with well audited open-source code.
# It is but a script that calls industry-standard OSS tools: SSL, GPG, Git.
# The encryption uses state of the art crypto via RSA keys and a GPG keys.

# The vault is just a directory tree, into which go our encrypted secrets.
# Thus secret names can be easily located, indexed, globbed, and queried.
# This open directory structure makes it extremely adaptable and flexible.

# The directory can also be a Git repo and can be shared over machines.
# It can also be shared with other users or multiple vaults can be used.

# The secret file format holds a plain text secret on its very first line;
# the rest of the file may contain metadata as name-value parameter pairs.

# You can use it for passwords, secrets, identity credentials, SSH PEM keys.
# They can be invoked or piped in a command-line or pasted to the clipboard.
# Pass has a plethora of extension plugins to integrate with other systems.

# The only extension we require is pass-file to encrypt entire files.
# We use this to encrypt SSH private keys and Certificate private keys.
# Now we could just secure keys with a passphrase - pass simplifies this
# by providing a single API interface to unify all our private secrets
# in a single vault with a single passphrase.


# Now because it is but a script that calls other minimal POSIX commands,
# we can adapt it and have a common interface for both Bash and Powershell.
# For added portability, we can implement the PowerShel.SecretManagement
# ISecureVault API and integrate with the windows application ecosystem.

# For extension plugins, the general design is the path comes last,
# in order to parse and shift subcommands and their option switches;
# that is, the very last non-switch arg should be a store pathname.

#
# Basic-Usage:
#
#   (*)
#   pass                                        [<path]
#   pass [list|ls]                              [<dir>]
#   pass [show|get]   [-c|clip]                 [<path>]
#   
#   (!) 
#   pass insert|set   [-f|force] [-m|multiline]  <path>
#       
#   pass help|usage
#
#   
# Special-Usage: 
#
#   (TODO)
#   pass vi|edit      <path>
#   pass rm|remove    [-f|force] [-r|recurse]    <path>
#   pass mv|move      [-f|force] [-r|recurse]    <path>  <dest>
#   pass cp|copy      [-f|force] [-r|recurse]    <path>  <dest>
#   
#
# Pass-File:
# 
#   (+)  
#   pass file add     <file>        <dir>
#   pass file get                   <dir/name>
#   
   
# Notes and Examples:
#
# Basic Usage:
#
# (*)
# Pass accepts a convenience shortcut invocation without a command.
# - will show the secret if the path maps a file (named $path.pgp).
# - will list the secrets if if the path masp to a directory name.
#
# dir:
#   pass      /ssh
#   pass list /ssh                 (equivalent if keys is a folder)
# 
# file: 
#   pass      /ssh/id_rsa 
#   pass show /ssh/id_rsa          (equivalent if id_rsa is a file)
#
# 
# (!)
# Pass is very POSIX and uses -f --force and -r --recurse switches,
# allowing to reorganise gpg secrets and their directrory structure;
# -m --multiline reads a multiline secret from stdin (EOD = CTRL-D).
#
# ex: "
#   pass insert -f /windows/ntlogin    (insert or replace a secret)
#

# Special Usage: 
#
#   (TODO)
#   pass vi|edit      <path> 
#   pass rm|remove    [-f|force] [-r|recurse]    <path> 
#   pass mv|move      [-f|force] [-r|recurse]    <from>  <path> 
#   pass cp|copy      [-f|force] [-r|recurse]    <from>  <path> 
#
#

# Pass-File:
#
# (+)
# Pass-File stores files in the subdirectory specified by the path:
# Note Pass-file works exactly like a reglar 'pass --multiline' call,
# the only difference being it does not prompt to enter the contents.
#
# 
# ex: 
#   pass file add   ~/.ssh/id_rsa   ssh   (will add to ssh subdir)
# 
#   pass file get   ssh/id_rsa
#   pass show       ssh/id_rsa           (equivalent for text files)
#

#
# If the file is text, 'pass show' works just like 'pass file get',
# file contents can be copied to the clipboard using 'pass --clip'.
# But if the file is binary, it outputs the raw binary file contents.
# In such case, you should redirect the binary output stream to a file.
#
# Note the binary machine encoding stays the same as its original creation,
# so if you share binary files across machines using git or other means,
# management of encoding is up to you (as it would be without pass or git).
#
# It does not currently allow to copy a binary COM object to clipboard,
# this would be great for images like QR codes (investigate COM images).
#
# On QR codes, the original pass command supports 'pass ---qrcode' and
# calls 'qrencode` to generate a QR code for a text secret or password,
# placing it on the XWindows clipboard (not sure which format GIF, SVG?).
# It should be possible to port this to windows, but that would require
# graphics components which we probably do not have on an institutional
# minimal thin client desktop.
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



# Usage Help
function Help {
    echo " "
    echo " Git-Pass is a port of the POSIX pass command (aka password-store), "
    echo " for institutional windows desktops using a limited Gitbash shell.  "
    echo " "
    echo " We have ported it to GitBash and coded an equivalent for PowerShell. "
    echo " The code is GPL and is lives at https://github.com/korningf/git-pass/ "
    echo " (c) copyleft-GPL 2025  Francis Korning de Grandpre fkorning@gmail.com "
    echo " "
    echo " See the original pass from Jason Donenfeld: https://passwordstore.org "
    echo " The OSS code is part of zx2c4: https://git.zx2c4.com/password-store/ "
    echo " "
    echo " "
    echo " Basic-Usage: "
    echo " "
    echo "   (*) "
    echo "   pass                                        [<path] "
    echo "   pass [list|ls]                              [<dir>] "
    echo "   pass [show|get]   [-c|clip]                 [<path>] "
    echo " "
    echo "   (!) "
    echo "   pass insert|set   [-f|force] [-m|multiline]  <name> "
    echo " "    
    echo "   pass help|usage "
    echo " "
    echo " "    
    echo " Special-Usage: "
    echo " "      
    echo "   (TODO)"
    echo "   pass vi|edit      <path> "
    echo "   pass rm|remove    [-f|force] [-r|recurse]    <path> "
    echo "   pass mv|move      [-f|force] [-r|recurse]    <path>  <dest> "
    echo "   pass cp|copy      [-f|force] [-r|recurse]    <path>  <dest> "
    echo " "
    echo " "
    echo " Pass-File: "
    echo " "
    echo "   (+)"
    echo "   pass file add     <file>        <dir> "
    echo "   pass file get                   <dir/name>  "
    echo " "
    echo " "
    echo " Notes: "
    echo " "
    echo " (*) "
    echo " Pass accepts a convenience shortcut invocation without a command. "
    echo " - will show the secret if the path maps a file (named path.pgp). "
    echo " - will list the secrets if if the path masp to a directory name. "
    echo " "
    echo " dir: "
    echo "   pass      /ssh "
    echo "   pass list /ssh                 (equivalent if keys is a folder) "
    echo " "
    echo " file: "
    echo "   pass      /ssh/id_rsa "
    echo "   pass show /ssh/id_rsa          (equivalent if id_rsa is a file) "
    echo " "
    echo " "
    echo " (!) "
    echo " Pass is very POSIX and uses -f --force and -r --recurse switches, "
    echo " allowing to reorganise gpg secrets and their directrory structure; "
    echo " -m --multiline reads a multiline secret from stdin (EOD = CTRL-D). "
    echo " "
    echo " ex: "
    echo "   pass insert -f /windows/ntlogin    (insert or replace a secret) "
    echo " "
    echo " "
    echo " (+) "
    echo " Pass-File stores files in the subdirectory specified by the path: "
    echo " "
    echo " ex: "
    echo "   pass file add   ~/.ssh/id_rsa   ssh   (will add to ssh subdir) "
    echo " "
    echo "   pass file get   ssh/id_rsa "
    echo "   pass show       ssh/id_rsa           (equivalent for text files) "
    echo " "
    echo " Note Pass-file works exactly like a reglar 'pass --multiline' call, "
    echo " the only difference being it does not prompt to enter the contents. "
    echo " "
    echo " If the file is text, 'pass show' works just like 'pass file get', "
    echo " file contents can be copied to the clipboard using 'pass --clip'. "
    echo " "
    echo " But if the file is binary, it outputs the raw binary file contents. "

    echo " In such case, you should redirect the binary output stream to a file. "
    echo " "
    echo " Binary file: "
    echo " "
    echo "    pass file add   ~/.ssh/id_rsa.der       ssh/id_rsa "
    echo "    pass file get   ssh/id_rsa.der      >   ~/.ssh/id_rsa.der "
    echo " "
    echo " "
}


# 

function List-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name        
    )
    $path = "$STORE\$name"

    echo "$path"
    #exit 0

    # root
    if ( "$name" -eq "" -or "$name" -eq "." -or "$name" -eq "/" -or "$name" -eq "\") {
       #tree /a /f "$path" | tail +4 | sed -e 's/\.gpg$//g'
       tree /a /f "$STORE" | tail +4
       return
    }

    # dir
    if ( [System.IO.Directory]::Exists("$path")) {
       echo ".\$name"
       #tree /a /f "$path" | tail +4 | sed -e 's/\.gpg$//g'
       tree /a /f "$path" | tail +4
       return
    }

    # file
    if ( [System.IO.File]::Exists("$path.gpg")) {
       echo ".\$name"
       return
    }

}

# Set-Secret
function Set-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name,
        [string]$force,
        [string]$multiline
    )
    $path = "$STORE\$name"

    if ( [System.IO.File]::Exists("$path.gpg")) {
       Write-Output "(INVALID insert): Secret $path.gpg already exists: Exiting."
       return
    }

    $input | gpg --output "$path.gpg" --encrypt --recipient "$Email"
}


# Get-Secret
function Get-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name
    )
    $path = "$STORE\$name"

    if (-not [System.IO.File]::Exists("$path.gpg")) {
       Write-Output "Secret $path.gpg not found: Exiting."
       return
    }

    $Secret = gpg --decrypt "$path.gpg" 2>$null

    echo $Secret
    
    return $Secret
}

# Del-Secret
function Del-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name,
        [string]$force,
        [string]$recurse
    )
    $path = "$STORE\$name"

    if (! [System.IO.File]::Exists("$path.gpg")) {
       Write-Output "(INVALID Remove): Secret $path.gpg not found: Exiting."
       exit 1
    }

    rm -f "$path.gpg"
}


# Move-Secret
function Move-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name,
        [string]$dest,        
        [string]$force
    )

    $source = "$STORE\$name"
    $target = "$STORE\$dest"

    # source directory
    if ([System.IO.Directory]::Exists("$source")) {
        mv "$force" "$source" "$target"
    }
    # source file
    elseif ([System.IO.File]::Exists("$source.gpg")) {
        mv "$force" "$source.gpg" "$target"
    }
    # source missing
    else {
       Write-Output "(INVALID move): Source $source not found: Exiting."
       exit 1
    }

}


# Copy-Secret
function Copy-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name,
        [string]$dest,        
        [string]$force,
        [string]$recurse
    )

    $source = "$STORE\$name"
    $target = "$STORE\$dest"

    # source directory
    if ([System.IO.Directory]::Exists("$source")) {
        cp "$force" "$recurse" "$source" "$target"
    }
    # source file
    elseif ([System.IO.File]::Exists("$source.gpg")) {
        cp "$force" "$recurse" "$source.gpg" "$target"
    }
    # source missing
    else {
       Write-Output "(INVALID copy): Source $source not found: Exiting."
       exit 1
    }

}


# Testors


# Test-Hardcoded

function Test-Hardcoded {
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


# Test-Parametrised

function test-Parametrised {
    param (
        [string]$name
    )

    # Set secret
    Set-Secret -Store $STORE -Email $EMAIL -Path "$name"

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -Path "$name"

    # Get secret
    $Secret = Get-Secret -Store $STORE -Email $EMAIL -Path "$name"
}





$name = ""
$subcmd = ""
$command = ""





#Test-Parametrised -$name $args[0]



# Arguments


# Commands
if ( $args.count -eq 0) {
    List-Secret -Store $STORE -Email $EMAIL
    exit 0
}

if ( $args.count -gt 0) {    
    $cmd = $args[0]

    # Basic-Commands

    # help
    if ( $cmd -eq "help" -or $cmd -eq "usage") {
        $command = "help"
        Help 
        exit
    }

    # list
    elseif ( $cmd -eq "ls" -or $cmd -eq "list") {
        $command = "list"
        $args = $args[1..($args.Length - 1)]

        # hack for empty args
        if ($args.count -le 0 -or $cmd -eq $args[0]) {
            echo "(EMPTY list): pass list $clip ($path)"
            List-Secret -Store $STORE -Email $EMAIL
            exit 0
        }

        $path = $args[0]
        echo "(PARSED list 1) pass list $clip ($path)"

        List-Secret -Store $STORE -Email $EMAIL -name "$path"
        exit 0
    }

    # show
    elseif ( $cmd -eq "show" -or $cmd -eq "get") {
        $command = "show"
        $args = $args[1..($args.Length - 1)]

        # switches
        foreach ($arg in $args) {
            # --clip
            if ( $arg -eq "-c" -or $arg -eq "--clip" ) {
                $clip = "-c"
                $args = $args[1..($args.Length - 1)]
            }
            # unknown option - skip it
            elseif ( $arg.StartsWith("-") ) {                
                $args = $args[1..($args.Length - 1)]
            }     
        }

        # hack for empty args
        if ($args.count -le 0 -or $cmd -eq $args[0]) {
            echo "(EMPTY show): pass show $clip ($path)"
            exit 1
        }

        $path = $args[0]
        echo "(PARSED show 1) pass show $clip ($path)"
        exit 0        
    }

    # insert
    elseif ( $cmd -eq "insert" -or $cmd -eq "set") {
        $command = "insert"
        $args = $args[1..($args.Length - 1)]

        # switches
        foreach ($arg in $args) {
            # --forcce
            if ( $arg -eq "-f" -or $arg -or $arg -eq "--force") {
                $force = "-f"
                $args = $args[1..($args.Length - 1)]
            }
            # --multiline
            elseif ( $arg -eq "-m" -or $arg -eq "--multiline") {
                $multiline = "-m"
                $args = $args[1..($args.Length - 1)]
            }
            # unknown option - skip it
            elseif ( $arg.StartsWith("-") ) {                
                $args = $args[1..($args.Length - 1)]
            }     
        }

        # hack for empty args
        if ($args.count -le 0 -or $cmd -eq $args[0]) {
            echo "(EMPTY insert): pass insert $force $multiline ($path)"
            exit 1
        }

        $path = $args[0]
        echo "(PARSED insert): pass insert $force $multiline ($path)"
        exit 0
    }

    # rm
    elseif ( $cmd -eq "rm" -or $cmd -eq "remove") {
        $command = "rm"
        $args = $args[1..($args.Length - 1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args = $args[1..($args.Length - 1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args = $args[1..($args.Length - 1)]
            }     
        }

        # hack for empty args
        if ($args.count -le 0 -or $cmd -eq $args[0]) {
            echo "(EMPTY rm): pass rm $force $recurs ($path)"
            exit 1
        }

        $path = $args[0]
        echo "(PARSED rm): pass rm $force $recurse ($path)"
        exit 0
    }

    # mv
    elseif ( $cmd -eq "mv" -or $cmd -eq "move") {
        $command = "mv"
        $args = $args[1..($args.Length - 1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args = $args[1..($args.Length - 1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args = $args[1..($args.Length - 1)]
            }     
        }

        # hack for empty args
        if ($args.count -le 1 -or $cmd -eq $args[0]) {
            echo "(INVALID mv): pass mv $force $recurse ($path) ($dest)"
            exit 1
        }

        $path = $args[0]
        $dest = $args[1]        
        echo "(PARSED mv): pass mv $force $recurse ($path) ($dest)"
        exit 0
    }

    # cp
    elseif ( $cmd -eq "cp" -or $cmd -eq "copy") {
        $command = "cp"
        $args = $args[1..($args.Length - 1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args = $args[1..($args.Length - 1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args = $args[1..($args.Length - 1)]
            }     
        }

        # hack for empty args
        if ($args.count -le 1 -or $cmd -eq $args[0]) {
            echo "(INVALID cp): pass cp $force $recurse ($path) ($dest)"
            exit 1
        }

        $path = $args[0]
        $dest = $args[1]        
        echo "(PARSED cp): pass cp $force $recurse ($path) ($dest)"
        exit 0
    } 

    # exotic commmands

    # find
    elseif ( $cmd -eq "find") {
        $command = "find"
        $args = $args[1..($args.Length - 1)]

        $path = $args[0]
        echo "(TODO find): pass find ($args)"
        exit
    } 
    # grep
    elseif ( $cmd -eq "grep") {
        $command = "grep"
        $args = $args[1..($args.Length - 1)]

        $path = $args[0]
        echo "(TODO grep): pass grep ($args)"
        exit
    } 
    # edit
    elseif ( $cmd -eq "edit") {
        $command = "edit"
        $args = $args[1..($args.Length - 1)]

        $path = $args[0]
        echo "(TODO edit): pass edit ($args)"
        exit
    } 


    # git
    elseif ( $cmd -eq "git") {
        $command = "git"
        $args = $args[1..($args.Length - 1)]

        $path = $args[0]
        echo "(TODO git): pass git ($args)"
        exit
    } 


    # extension commands

    # file
    elseif ( $cmd -eq "file") {
        $command = "file"
        $args = $args[1..($args.Length - 1)]

        if ($args.count -lt 2) {
            exit "(INVALID file): pass file ? ($args)"
        }
        $subcmd = $args[0]
        $args = $args[1..($args.Length - 1)]

        if ( $subcmd -eq "get") {
            $name = $args[0]
            echo "(PARSED file get): pass file get ($args)"
            exit
        }

        if ( $subcmd -eq "set") {

            if (! $args.count -gt 1) {
                exit "(INVALID file set): pass file set ($args)"
            }

            $file = $args[0]
            $name = $args[1]
            echo "(PARSED file set): pass file set ($args)"
            exit
        }
    }

    echo "(PARSED) $Command $subcmd $args"
    exit
}

