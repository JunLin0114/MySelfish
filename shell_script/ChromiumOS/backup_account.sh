#!/bin/sh
# Backup file ~/.gitcookies to ~/gitcookies.name
# Backup file ~/.netrc to ~/.netrc.name
account_name=${1:-}
gitcookies_file=$HOME/.gitcookies
netrc_file=$HOME/.netrc
if [ -z $account_name ]; then
  echo "account_name not specified"
  exit 1
fi
_exit_error()
{
  echo "file $1 not exit"
  exit 1
}
gitcookies_account_file=$gitcookies_file.$account_name
netrc_account_file=$netrc_file.$account_name
[ ! -f "$gitcookies_file" ] && _exit_error $gitcookies_file 
[ ! -f "$netrc_file" ] && _exit_error $netrc_file
cp $gitcookies_file $gitcookies_account_file 
cp $netrc_file $netrc_account_file 
