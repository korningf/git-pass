# Git-Pass 


  *Minimal Windows POSIX pass command*

  

Git-Pass is a port of the POSIX pass command (aka password-store) 

for a minimal Windows POSIX (GitBash, SysGit, MSys, MSys2, MinG64).


# Abstract

Though password-store is a bash .sh script, it installs via a Makefile.

Make may not be present on every system, and the .sh script is broken.

I've patched it to work on gitbash (will probably work on the others).


#  Preparation

Have an email identity to be used with the following:

      - SSH keypair
      - GPG keyring
      - Git account


#  Installation


      ./install.sh


# Configuration

Pick a (Memorable Passphrase)[https://strongphrase.net/]


Generate your GPG keyring

      gpg --gen-key


Use following parameters

   key kind:      1 (RSA)
   key size:      4096
   validity:      0 (never expires)




# Operation


_TODO_


#  Attribution

The code is 99.999% verbatim from password-store by Jason Donenfeld.

[Original README](README)

[Original project](https://www.passwordstore.org/)

[Original source](https://git.zx2c4.com/password-store/)




[Original README] (README)
