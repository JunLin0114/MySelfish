git_archive () {
  commit=HEAD
  file_output=HEAD
  if [ -z "$1" ];then
    echo "No Branch or commit ID Specified, Use HEAD "
    git archive HEAD -o HEAD.tar.gz `git diff --name-only HEAD^ HEAD`
  else
    echo "Search Local Branch $1 ........"
    git show-ref --verify --quiet refs/heads/$1
	if [ $? -ne 0 ]; then
	  echo "  Local Branch not exist!"
	else
	  echo "Found!! Start to tar the changed files"
      commit=$1
      git archive $commit -o ${commit}.tar.gz `git diff --name-only ${commit}^ ${commit}`
	  return 0
    fi
    echo "Search Remote $1 ........" 
    git show-ref --verify --quiet refs/remotes/$1
	if [ $? -ne 0 ]; then
	  echo "  remote Branch not exist!"
	else
	  echo "Found!! Start to tar the changed files"
      commit=$1
	  file_output=${commit/\//_}
      echo "${file_output}"
      git archive $commit -o ${file_output}.tar.gz `git diff --name-only ${commit}^ ${commit}`
	  return 0
	fi
    echo "Search Tags $1 ........" 
    git show-ref --verify --quiet refs/tags/$1
	if [ $? -ne 0 ]; then
	  echo "  Tags not found!"
	else
	  echo "Found!! Start to tar the changed files"
      commit=$1
      git archive $commit -o ${commit}.tar.gz `git diff --name-only ${commit}^ ${commit}`
	  return 0
    fi
    echo "Search Commit ID => $1 ........" 
    git cat-file -e $1
	if [ $? -ne 0 ]; then
	  echo "  Not a Valid Commit ID! "
	  echo "git_archive Fail!!!"
	  return 1
	else
	  echo "Found!! Start to tar the changed files"
      commit=$1
      git archive $commit -o ${commit}.tar.gz `git diff --name-only ${commit}^ ${commit}`
	  return 0
    fi
    
  fi 
  return 0
}
