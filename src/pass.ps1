#!/usr/bin/env powershell

'$PSCommandPath: ' + $PSCommandPath
'$MyInvocation.MyCommand.Path: ' + $MyInvocation.MyCommand.Path
'$MyInvocation: ' + ($MyInvocation | Out-String)

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
# The encryption uses state of the art crypto via RSA keys and GNUGPG keys.

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
# allowing to reorganise gpg secrets and their directory structure;
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

# Pass-Sign sign
#
# So it dawns on me that we could benefit from signing and verifying.
# providing a signature would support many shared secret scenarios.
# 
# if we use detached ascii-armored .asc signatures to accompany a .gpg,
# as a bonus we can attach any number of comment lines with metadata.
# 

# extract metadata from original:
#
# use the file cmd to extract metadata: signer, mime-type, encoding.
#
#    filename=`filename $file`
#    filetype=`file $file | sed -e 's/^.*: //g'` 
#    mimetype=`file mime-type $file`
#    encoding=`file mime-encoding $file`
#    bytelen=`wc -c $file`
#    charlen=`wc -m $file`
#    linelen=`wc -l $file`
#

# sign the original with meta-data:
#
# sign encrypted file in a detached ascii armored signature (.asc)
# adding the metadata as plain-text comments (1 name=value per line).
#
#    path="$STORE/$name.gpg"
#
#    cat $path.gpg | gpg --detach-sign --armor --output $path.asc \
#       --comment signer=FrancisKorning@welfare.ie \
#       --comment "filename=id_rsa"  --comment "mimetype=text/plain" 
#       --comment "filetype=OpenSSH private key"  --comment "encoding=us-ascii" \
#       --comment "bytelen=2675" --comment "charlen=2675" --comment "linelen=39"\
#

# Pass-Sign info
#
# print the metadata:
#
#   cat $path.asc | grep Comment | sed -e 's/Comment: //g'
#
#   signer=FrancisKorning@welfare.ie
#   filename=id_rsa
#   filetype=OpenSSH private key
#   mimetype=text/plain
#   encoding=us-ascii
#   bytelen=2675
#   charlen=2675
#   linelen=39

# Pass-Sign verify
#
# verify the .gpg with the .asc
#
#   gpg --verify $path.asc $path.gpg
#
#   gpg: Signature made Wed, Oct  1, 2025  9:03:53 AM GMTDT
#   gpg:                using RSA key A7971F081CD28915A2ED831426F423FFE06775FC
#   gpg: Good signature from "Francis Korning <FrancisKorning@welfare.ie>" [ultimate]
#




# PowerShell Class (TODO)
#
# expose this as an ISecretVault and/or ISecretStore


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
    echo "   pass                                        [<name>] "
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
    echo " allowing to reorganise gpg secrets and their directory structure; "
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


# List-Secret
# we try to replicate the output from the original POSIX pass command.
# the asci-art tree command output is slightly different for its trees,
# and we're not sure if we want to show or hide .gpg file extensions yet.

function List-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name        
    )
    $item = "$STORE\$name"

    echo "$item"
    #exit 0

    # root
    if ( "$name" -eq "" -or "$name" -eq "." -or "$name" -eq "/" -or "$name" -eq "\") {
       #tree /a /f "$item" | tail +4 | sed -e 's/\.gpg$//g'
       tree /a /f "$STORE" | tail +4
       return
    }

    # dir
    if ( [System.IO.Directory]::Exists("$item")) {
       echo ".\$name"
       #tree /a /f "$item" | tail +4 | sed -e 's/\.gpg$//g'
       tree /a /f "$item" | tail +4
       return
    }

    # file
    if ( [System.IO.File]::Exists("$item.gpg")) {
       echo ".\$name"
       return
    }

}


# Set-Secret
# We might rename this to Add-Secret or Insert-Secret
# and we may add cod to store signature and metadadata.

function Set-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name,
        [string]$force,
        [string]$multiline
    )
    $item = "$STORE\$name"

    if ( [System.IO.File]::Exists("$item.gpg")) {
       Write-Output "(INVALID insert): Secret $item.gpg already exists: Exiting."
       return
    }

    $input | gpg --output "$item.gpg" --encrypt --recipient "$Email"
}


# Get-Secret
# because pass has a fuzzy context where it can show a secret or list secrets
# depending on whether the target name is a .gpg secret file or a directory,
# we decouple Show-Secret from underlying Get-Secret or List-Secret functions.

function Get-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name
    )
    $item = "$STORE\$name"

    if (![System.IO.File]::Exists("$item.gpg")) {
       Write-Output "Secret $item.gpg not found: Exiting."
       return
    }

    $Secret = gpg --decrypt "$item.gpg" 2>$null

    #echo $Secret
    
    return $Secret
}


# Show-Secret
# because pass has a fuzzy context where it can show a secret or list secrets
# depending on whether the target name is a .gpg secret file or a directory,
# we decouple Show-Secret from underlying Get-Secret or List-Secret functions.

function Show-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name
    )
    $item = "$STORE\$name"

    if ([System.IO.Directory]::Exists("$item")) {
        List-Secret -Store $Store -Email $Email -name $name
        return
    }

    if ([System.IO.File]::Exists("$item.gpg")) {
        Get-Secret -Store $Store -Email $Email -name $name
       return
    }

    $Secret = gpg --decrypt "$item.gpg" 2>$null

    #echo $Secret
    
    return $Secret
}


# Clip-Secret
# The original POSIX pass command only adds show secret contents to the clipboard.
# It would be useful to add the ascii tree output of a list secret command as well.

function Clip-Secret {
    param (
        [string]$Store,
        [string]$Email,
        [string]$name
    )
    $item = "$STORE\$name"

    if ([System.IO.Directory]::Exists("$item")) {
        List-Secret -Store $Store -Email $Email -name $name | Get-Content | Set-Clipboard
        return
    }

    if ([System.IO.File]::Exists("$item.gpg")) {
        Get-Secret -Store $Store -Email $Email -name $name | Get-Content | Set-Clipboard
       return
    }
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
    $item = "$STORE\$name"


    # directory
    if ([System.IO.Directory]::Exists("$item")) {
        #Write-Output "Remove folder: rm $force $recurse $item"        
        rm -Path "$item"
        exit 0
    }

    # secret file
    elseif ([System.IO.File]::Exists("$item.gpg")) {
        #Write-Output "Remove secret: rm $force $recurse $item.gpg"        
        rm -Path "$item.gpg"
        exit 0
    }

    # not found
    else {
       Write-Output "INVALID Remove: Path $item not found: Exiting."
       exit 1
    }
    
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
        mv -Path "$source" -Destination "$target"
    }
    # source file
    elseif ([System.IO.File]::Exists("$source.gpg")) {
        mv -Path "$source.gpg" -Destination "$target"
    }
    # source missing
    else {
       Write-Output "INVALID move: Source $source not found: Exiting."
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
        cp -Path "$source" -Destination "$target"
    }
    # source file
    elseif ([System.IO.File]::Exists("$source.gpg")) {
        cp -Path "$source.gpg" -Destination "$target"
    }
    # source missing
    else {
       Write-Output "INVALID copy: Source $source not found: Exiting."
       exit 1
    }

}


# Pass-File

# Add-File
function Add-File {
    param (
        [string]$Store,
        [string]$Email,
        [string]$file,
        [string]$dest,
        [string]$force,
        [string]$recurse
    )
    $source = $file
    $name = Split-Path -Path $file -Leaf`
    $folder = "$STORE\$dest"
    $target = "$STORE\$dest\$name"

    # source
    if (! [System.IO.File]::Exists("$source")) {
        Write-Output "(PASS-File add): File $source does not exist: Exiting."
        return
    }

    # folder
    if (! [System.IO.Directory]::Exists("$folder")) {
        Write-Output "(PASS-File add): Folder $folder does not exist: Creating it."
        return
    }

    # target
    if ([System.IO.File]::Exists("$target.gpg")) {
        Write-Output "(PASS-File add): Secret $target.gpg already exists: Exiting."
        return
    }

    cat $source | gpg --output "$target.gpg" --encrypt --recipient "$Email"
}


# Pass-Sign

# Pass-Info
function Pass-Info {
    param (
        [string]$Store,
        [string]$Email,
        [string]$file,
        [string]$name
    )
    
    if (! [System.IO.File]::Exists("$file")) {
       Write-Output "(INVALID sign): File $file does not exists: Exiting."
       return
    }


    #$mime = [System.Web.MimeMapping]::GetMimeMapping($file)      
    $filetype = file "$file" | sed -e 's/^.*: //g'
    $mimetype = file "$file ---mime-type" | sed -e 's/^.*: //g'
    $encoding = file "$file ---mime-encoding" | sed -e 's/^.*: //g'

    $bytelen = wc -c "$file"
    $charlen = wc -m "$file"
    $linelen = wc -l "$file"
}


# Pass-Sign
function Pass-Sign {
    param (
        [string]$Store,
        [string]$Email,
        [string]$file,        
        [string]$name,
        [string]$filetype,
        [string]$mimetype,
        [string]$encoding
    )
    $item = "$STORE\$name"

    if (! [System.IO.File]::Exists("$item.gpg")) {
       Write-Output "(INVALID sign): Secret $item.gpg does not exists: Exiting."
       return
    }

    cat "$file.gpg" | gpg --detach-sign --output "$item.asc" --armor --recipient "$Email" --comment "filetype=$filetype"  --comment "mimetype=$mimetype"  --comment "encoding=$encoding"

}



# Testors


# Test-Hardcoded

function Test-Hardcoded {
    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name ""

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name "."

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name "ssh"

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name "windows"

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name "windows\ntlogin"

    # Set secret
    #Set-Secret -Store $STORE -Email $EMAIL -name "windows\ntlogin" -Secret $Secret -Param "name=value"

    # Get secret
    Get-Secret -Store $STORE -Email $EMAIL -name "windows\ntlogin"

    # Show secret
    Show-Secret -Store $STORE -Email $EMAIL -name "windows"    
    Show-Secret -Store $STORE -Email $EMAIL -name "windows\ntlogin"
}


# Test-Parametrised

function test-Parametrised {
    param (
        [string]$name
    )

    # Set secret
    #Set-Secret -Store $STORE -Email $EMAIL -name "$name"

    # List secret
    List-Secret -Store $STORE -Email $EMAIL -name "$name"

    # Get secret
    Get-Secret -Store $STORE -Email $EMAIL -name "$name"

    # Show secret
    Show-Secret -Store $STORE -Email $EMAIL -name "windows"    
    Show-Secret -Store $STORE -Email $EMAIL -name "windows\ntlogin"
}





$name = ""
$cmd = ""
$subcmd = ""
#$command = ""
#$subcommand = ""




#Test-Parametrised -name $args[0]



# Arguments

# what a nightmare
#
# The general principle of POSIX commands is that the path object being manipulated
# usually comes last in a command invocation, allowing us to use the shift operator
# to parse the command, subcommands, and all the the other options and switches.
#
# Unfortunately PowerShell has no shift operator, so we do it by slicing the array.
#
# But slicing has a feature(bug?): it does not remove the very last argument.
# As slicing [1..0] is meaningless, the result is it does not slice at all.
# This means in those cases, the last remaining arg stays on the arg stack.
#
# the flow that works we clear the arg being popped 
# and check for the last arg being the last command:
#
#    $args[0] = ""
#    $args = $args[1..($args.Length -1)]
#    ...
#    # Fail if empty
#    if ($args.count -lt 1 -or $args[0] -eq "$cmd") {
#    ... 
#

# Commands
if ( $args.count -eq 0) {
    Write-Output "(PARSED 0) pass list ($args)"
    Show-Secret -Store $STORE -Email $EMAIL
    exit 0
}

if ( $args.count -gt 0) {    
    $cmd = $args[0]

    # Basic-Commands

    # help
    if ( $cmd -eq "help" -or $cmd -eq "usage") {
        $command = "help"
        Help 
        exit 0
    }

    # list
    elseif ( $cmd -eq "ls" -or $cmd -eq "list") {
        $command = "list"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            # --clip
            if ( $arg -eq "-c" -or $arg -eq "--clip" ) {
                $clip = "-c"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            # unknown option - skip it
            elseif ( $arg.StartsWith("-") ) {
                $args[0] = ""
                $args = $args[1..($args.Length -1)]                
            }
        }

        # List Null
        if ($args.count -lt 1 -or $args[0] -eq "") {
            # List-Secret
            $path = ""
            Write-Output "PARSED: pass list $clip $path ($($args.Count) args = [$args])"
            
            List-Secret -Store $STORE -Email $EMAIL -name "$path"
            exit 0
        }

        # List Path
        $path=$args[0]
        Write-Output "PARSED: pass list $clip $path ($($args.Count) args = [$args])"

        List-Secret -Store $STORE -Email $EMAIL -name "$path"
        exit 0
    }

    # show
    elseif ( $cmd -eq "show" -or $cmd -eq "get") {
        $command = "show"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            # --clip
            if ( $arg -eq "-c" -or $arg -eq "--clip" ) {
                $clip = "-c"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            # unknown option - skip it
            elseif ( $arg.StartsWith("-") ) {
                $args[0] = ""
                $args = $args[1..($args.Length -1)]                
            }
        }

        # Show Null
        if ($args.count -lt 1 -or $args[0] -eq "") {
            # Show-Secret
            $path = ""
            Write-Output "PARSED: pass show $clip $path ($($args.Count) args = [$args])"
            
            Show-Secret -Store $STORE -Email $EMAIL -name "$path"
            exit 0
        }

        # Show Path
        $path=$args[0]
        Write-Output "PARSED: pass show $clip $path ($($args.Count) args = [$args])"

        Show-Secret -Store $STORE -Email $EMAIL -name "$path"
        exit 0
    }

    # insert
    elseif ( $cmd -eq "insert" -or $cmd -eq "set") {
        $command = "insert"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            # --force
            if ( $arg -eq "-f" -or $arg -or $arg -eq "--force") {
                $force = "-f"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            # --multiline
            elseif ( $arg -eq "-m" -or $arg -eq "--multiline") {
                $multiline = "-m"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            # unknown option - skip it
            elseif ( $arg.StartsWith("-") ) {
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }     
        }

        # hack for empty args
        if ($args.count -lt 1 -or $args[0] -eq "") {
            Write-Output "EMPTY insert: pass insert $force $multiline $path ($($args.Count) args = [$args])"
            exit 1
        }

        $path = $args[0]
        Write-Output "PARSED insert: pass insert $force $multiline $path ($($args.Count) args = [$args])"
        
        Set-Secret -Store $STORE -Email $EMAIL $force $multiline -name "$path"
        exit 0
    }

    # rm
    elseif ( $cmd -eq "rm" -or $cmd -eq "remove") {
        $command = "rm"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }     
        }

        # hack for empty args
        if ($args.count -lt 1 -or $args[0] -eq "") {
            Write-Output "EMPTY rm: pass rm $force $recurse $path ($($args.Count) args = [$args])"
            exit 1
        }

        $path = $args[0]
        Write-Output "PARSED rm: pass rm $force $recurse $path ($($args.Count) args = [$args])"
        
        Del-Secret -Store $STORE -Email $EMAIL $force $recurse -name "$path"
        exit 0
    }

    # mv
    elseif ( $cmd -eq "mv" -or $cmd -eq "move") {
        $command = "mv"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }     
        }

        # hack for empty args
        if ($args.count -lt 2 -or $args[0] -eq "") {
            Write-Output "INVALID mv: pass mv $force $recurse $path $dest ($($args.Count) args = [$args])"
            exit 1
        }

        $path = $args[0]
        $dest = $args[1]        
        Write-Output "PARSED mv: pass mv $force $recurse $path $dest ($($args.Count) args = [$args])"

        Move-Secret -Store $STORE -Email $EMAIL $force $recurse -name "$path" -dest "$dest"
        exit 0
    }

    # cp
    elseif ( $cmd -eq "cp" -or $cmd -eq "copy") {
        $command = "cp"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # switches
        foreach ($arg in $args) {
            if ( $arg -eq "-f" -or $arg -eq "--force") {
                $force = "-f"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }
            elseif ( $arg -eq "-r" -or $arg -eq "--recurse") {
                $recurse = "-r"
                $args[0] = ""
                $args = $args[1..($args.Length -1)]
            }     
        }

        # hack for empty args
        if ($args.count -lt 2 -or $args[0] -eq "") {
            Write-Output "INVALID cp: pass cp $force $recurse $path $dest ($($args.Count) args = [$args])"
            exit 1
        }

        $path = $args[0]
        $dest = $args[1]        
        Write-Output "PARSED cp: pass cp $force $recurse $path $dest ($($args.Count) args = [$args])"
        
        Copy-Secret -Store $STORE -Email $EMAIL $force $recurse -name "$path" -dest "$dest"
        exit 0
    } 

    # exotic commmands

    # find (TODO)
    elseif ( $cmd -eq "find") {
        $command = "find"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        $path = $args[0]
        Write-Output "UNSUPPORTED find (TODO): pass find $path $expr ($($args.Count) args = [$args])"
        
        exit 0
    } 

    # grep (TODO)
    elseif ( $cmd -eq "grep") {
        $command = "grep"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        $path = $args[0]
        $expr = ""
        Write-Output "UNSUPPORTED grep (TODO): pass grep $path $expr ($($args.Count) args = [$args])"
        
        exit 0
    } 

    # edit (TODO)
    elseif ( $cmd -eq "edit") {
        $command = "edit"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        $path = $args[0]
        Write-Output "UNSUPPORTED edit (TODO): pass edit $path ($($args.Count) args = [$args])"
        
        exit 0
    } 


    # git
    elseif ( $cmd -eq "git") {
        $command = "git"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        $path = $args[0]
        $subcmd = ""
        $options = ""
        Write-Output "UNSUPPORTED git (TODO): pass git $subcmd $options $path ($($args.Count) args = [$args])"        
        
        exit 0
    } 


    # extension commands

    # file
    elseif ( $cmd -eq "file") {
        $command = "file"
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        # hack for empty args
        if ($args.count -le 1 -or $args[0] -eq "") {
            Write-Output "(INVALID file - missing subcommand): pass file ? ($path)"
            exit 1
        }

        $subcmd = $args[0]
        $args[0] = ""
        $args = $args[1..($args.Length -1)]

        if ( $subcmd -eq "g" -or $subcmd -eq "get" ) {
            $subcommand = "get"
            $name = $args[0]

            Write-Output "(PARSED file get): pass file get ? ($args)"
            
            exit 0
        }

        if ( $subcmd -eq "a" -or $subcmd -eq "add") {
            $subcommand = "add"

            if (! $args.count -gt 1) {
                Write-Output "(INVALID file add): pass file add ? ? ($args)"
                exit 1
            }

            $file = $args[0]
            $name = $args[1]
            Write-Output "(PARSED file set): pass file add ? ? ($args)"
            
            exit 0
        }
    }

    # default: show
    Write-Output "(PARSED 1) ($args)"

    $name = $args[0]
    Show-Secret -Store $STORE -Email $EMAIL -name "$name" 
    exit 0
}

