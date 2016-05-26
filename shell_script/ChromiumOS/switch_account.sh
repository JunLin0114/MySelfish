#!/bin/sh
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
[ ! -f "$gitcookies_account_file" ] && _exit_error $gitcookies_account_file 
[ ! -f "$netrc_account_file" ] && _exit_error $netrc_account_file
cp $gitcookies_account_file $gitcookies_file
cp $netrc_account_file $netrc_file 
