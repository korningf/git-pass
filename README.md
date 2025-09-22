# Git-Pass 


  *Minimal Windows POSIX pass command*


Git-Pass is a port of the POSIX pass command (aka password-store) 

for a minimal Windows POSIX (GitBash, SysGit, MSys, MSys2, MinG64).



![win-git-pass-file-ssh-pubkey](win-git-pass-file-ssh-pubkey.png "Windows Git-Pass ssh-pubkey")




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



#  Documentation

For the TLDR keep on reading this doc and following instructions.

Browse the official password-store docs For further documentation.

    https://www.passwordstore.org/



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



# Configuration


### Memorable Passphrase

Pick a (Memorable Passphrase)[https://strongphrase.net/]


### GPG KeyRing

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


### Password-Store

Create a .password-store git repo:

    cd ~
    mkdir -p .password-store
    git init .password-store

Sample Output:

    Initialized empty Git repository in C:/Users/JohnDoe/.password-store/.git/


Initialize the password-store.

    pass init .password-store ${gpg_id}


Sample Output:

    Password store initialized for .password-store, for identity: JohnDoe@Email.com.
    [master (root-commit) e6bcfa6] Set GPG id to .password-store, JohnDoe@Email.com.
     1 file changed, 2 insertions(+)
     create mode 100644 .gpg-id
 



### Unseal (De-Armor) a Secret

The passphrase is needed to dearmor the vault the 1st time we unseal any secret.

Pass will remember the passphrase within a session (Or if we run a GPG-Agent).

On Windows, this will use the Windows secure PIN entry dialog


![win-gpg-pin-passphrase-dialog](win-gpg-pin-passphrase-dialog.png "On windows the PIN dialog is used to enter the master passphrase")



# Operation


### Store a secret (Windows login)

As an example, we store our windows login in the path `windows/ntlogin`.

Note GPG uses the public key to encrypt (and the private key to decrypt).

This means we do not need to provide a passphrase to create a new secret.

_where (***********) is a placeholder for your windows ntlogon password_.


    pass insert windows/ntlogin 

     Enter password for windows/ntlogin:  ***********
     Retype password for windows/ntlogin: ***********
     [master 6ebe58e] Added given password for windows/ntlogin to store.
      1 file changed, 0 insertions(+), 0 deletions(-)
      create mode 100644 windows/ntlogin.gpg


### List secrets

    pass
     Password Store
     `-- windows
         `-- ntlogin


### Use a secret (windows login)

The default usage mode is to print the secret on stdout.

_where (***********) is your windows ntlogon password_.

    pass windows/ntlogin

    ***********


### Limitations

The principle behind pass is that it had to be a simple 100% bash command-line script.

By design pass does one simple thing well: it stores a one-line secret in a text file.

The text file can append name=value parameter pairs, but the first line is the secret.





# Extensions

Now the simple design allows for additional bash extension scripts.

For now, the only extension we require is pass-file (file secrets).

We will add Keepass, Hashicorp vault, and brower plugins later (TODO).



### pass-file


Pass-file allows us to store complete files as secrets (instead of 1-line).

That is, we can use it for multi-line secrets and even for secret binary files:

SSH + X.509 keys, Docker + Kubernetes Secrets, AWS-CLI + Azure-Cli Access-Keys.


    see [Pass-File](https://github.com/dvogt23/pass-file)


    pass file help



# Authentication


With Pass-File we can automate various authentication and authorizations.



## SSH Keypair



Generate your SSH keypair:

    ssh-keygen -t rsa -b 4096 -C JohnDoe@email.com


Insert the keypair in your vault

    pass file  add ~/.ssh/id_rsa.pub   ssh/id_rsa/ids_rsa.pub
    pass file  add ~/.ssh/id_rsa       ssh/id_rsa/ids_rsa


Delete the SSH private key (optional)



## Agent Forwarding

_TODO_

* Add SSH-Agent
  
* Add GPG-Agent



## Agent Tunneling


### DMZ Bastion

### Azure access

### AWS access

### Docker secrets

### Kubernetes secrets



# Automation

_TODO_

    gpg_id=`gpg --list-secret-keys | head -5 | grep uid | xargs | cut -d ' ' -f 5 | tr '<>' '  ' | tee` 2>/dev/null
    gpg_hash=`gpg --list-secret-keys | head -5 | grep 'sec ' | xargs | cut -d ' ' -f 2`

_TODO_




# TODO

_The next step is to figure out an organisational structure_

_set up agent-forwarding: pick either ssh-agent or gpg-agent_

* evaluate  [win-gpg-agent](https://github.com/rupor-github/win-gpg-agent)

* evaluate  [choco win-gpg-agent](https://community.chocolatey.org/packages/win-gpg-agent)
  


#  Attribution


### Pass on Git

Stephane Korning (stefuss@yahoo.com) for the idea to port POSIX pass to Gitbash.



### Pass

The Pass code is 99.999% verbatim from password-store by Jason Donenfeld.

The patch is basically just packaging of install.sh, and Tree and pass-file.

[Original README](README)

[Original project](https://www.passwordstore.org/)

[Original source](https://git.zx2c4.com/password-store/)


### Tree

In addition, the Tree command is from the Gnuwin32 project (GNU devs).

[Tree command](https://en.wikipedia.org/wiki/Tree_(command))

[Gnuwin32 project](https://en.wikipedia.org/wiki/GnuWin32)

[Gnuwin32 source] (https://sourceforge.net/projects/gnuwin32/)



## Pass-File

The Pass-File extension is 100% bash from (Dima) Dimitrij Vogt (GNU License).

[Pass-File](https://github.com/dvogt23/pass-file)

There is another Pass-File bash extension from Lukas Kropatschk (MIT license).

[Pass-File](https://github.com/lukrop/pass-file/) 

_TODO evaluate which is better ? - sticking to the GNU license one for now !_


# LICENSE

GNU GPL, as per [LICENSE](LICENSE)
