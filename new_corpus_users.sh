#!/bin/sh

# run this script as superuser
# new users:
# - members of: cvs, bound
# - get .bash_profile, .bashrc and .emacs from /etc/skel
# - do a fresh cvs co xtdoc gt words st, with needed ln -s

useradd $1 -G cvs,bound
su $1 -c "\
cd; \
cvs co xtdoc gt words st kt; \
ln -s /home/$1/words/doc xtdoc/sd/src/documentation/content/xdocs/wordsdoc; \
ln -s /home/$1/gt/doc xtdoc/sd/src/documentation/content/xdocs/.; \
ln -s /home/$1/gt/doc xtdoc/gtuit/src/documentation/content/xdocs/.;\
ln -s /home/$1/st/foe/doc xtdoc/gtuit/src/documentation/content/xdocs/foedoc;\
ln -s /home/$1/st/kal/doc xtdoc/gtuit/src/documentation/content/xdocs/kaldoc;\
ln -s /home/$1/kt/kom/doc xtdoc/gtuit/src/documentation/content/xdocs/komdoc;\
ln -s /home/$1/words xtdoc/gtuit/src/documentation/content/xdocs/."
