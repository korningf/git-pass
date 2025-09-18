# Git-Pass 


  *Minimal Windows POSIX pass command*

  

Git-Pass is a port of the POSIX pass command (aka password-store) 

for a minimal Windows POSIX (GitBash, SysGit, MSys, MSys2, MinG64).


# Motivation

Though password-store is a bash .sh script, it installs via a Makefile.

Make may not be present on every system, and the .sh script is broken.

I've patched it to work on gitbash (will probably work on the others).


#  Abstract

This workflow is entirely based on portable, simple POSIX command-line.

Password-Store is a secure Secrets-Vault aka a Secure Password-Manager.

It is basically a POSIX directory structure, encrypted via a passphrase.

The encryption uses state of the art RSA 4096 keys and a GnuPG keyring.

The directory structure is a Git repo, so it can be shared on machines.

Each file in a .password-store directory holds a secret and parameters.

The organisation therein is up to you (up to organisation's standards).

Typically, you put your SSH PEM keys, passwords, secrets, credentials.

You use them from the command-line by unsealing them with the passphrase.

There are a plethora of extension plugins that integrate password-store.




#  Preparation

Have an email identity to be used with the following:

    - SSH keypair
    - GPG keyring
    - Git account

Example:

    name:  John Doe
    email: JohnDoe@email.com
   

#  Installation


    ./install.sh


# Extension


## pass-file

Pass-file allows us to upload files as secrets, useful for X.509 certs, SSH key pairs, etc.

see [Pass-File](https://github.com/dvogt23/pass-file)


pass-file is just a bash script so we can place it directly in the pass extensions directory.

install via bash
   
```bash
    mkdir -p /usr/lib/password-store/extensions
    cd /usr/lib/password-store/extensions
   
    curl https://raw.githubusercontent.com/lukrop/pass-file/refs/heads/master/file.bash > file.bash
    chmod a+x *.bash
    cd
```



# Configuration

Pick a (Memorable Passphrase)[https://strongphrase.net/]


Generate your SSH keypair:

    ssh-keygen -t rsa -b 4096 -C JohnDoe@email.com


Generate your GPG keyring:

    gpg --gen-key


Use following parameters:

    key kind:      1 (RSA)
    key size:      4096
    validity:      0 (never expires)


Sample output:

    Real name: John Doe
    Email address: JohnDoe@email.com
    You selected this USER-ID:
      "John Doe <JohnDoe@email.com>"


Create a .password-store git repo:

    cd ~
    mkdir -p .password-store
    git init .password-store

Sample Output:

    Initialized empty Git repository in C:/Users/JohnDoe/.password-store/.git/



Initialize the password-store.

    pass init .password-store ${gpg_id}


Sample Output:

    Password store initialized for .password-store, FrancisKorning@welfare.ie
    [master (root-commit) e6bcfa6] Set GPG id to .password-store, FrancisKorning@welfare.ie.
     1 file changed, 2 insertions(+)
     create mode 100644 .gpg-id
 


# Operation


Store your Windows login

    pass insert windows/ntlogin #ThisIsAsecure6WordPassphrase!

    pass windows/ntlogin

    #ThisIsAsecure6WordPassphrase!



_TODO_


# Automation

_TODO_

    gpg_id=`gpg --list-secret-keys | head -5 | grep uid | xargs | cut -d ' ' -f 5 | tr '<>' '  ' | tee` 2>/dev/null
    gpg_hash=`gpg --list-secret-keys | head -5 | grep 'sec ' | xargs | cut -d ' ' -f 2`



# Tunneling


## DMZ Bastion

## Azure access

## AWS access




_TODO_

* Add SSH-Agent
  
* Add GPG-Agent

  
  

#  Attribution

The code is 99.999% verbatim from password-store by Jason Donenfeld.

[Original README](README)

[Original project](https://www.passwordstore.org/)

[Original source](https://git.zx2c4.com/password-store/)


In addition, the Tree command is from the Gnuwin32 project (and Gnuwin64).

[Tree command](https://en.wikipedia.org/wiki/Tree_(command))

[Gnuwin32 project](https://en.wikipedia.org/wiki/GnuWin32)

[Gnuwin32 source] (https://sourceforge.net/projects/gnuwin32/)

