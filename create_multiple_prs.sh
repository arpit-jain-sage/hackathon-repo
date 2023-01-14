#!/bin/sh

declare CURRENT_BRANCH FILES_COUNT FILES_NAMES FILES ISSUE_ID MODULE_NAME COMMIT_MESSAGE PR_DESSCRIPTION PR_TITLE PR_MODE;

greet() {
  print_divider "star";
  echo "Hello! Welcome to the Sage Inacct Hackathon Automation Universe.";
  print_divider "star";
  echo "NOTE: Please make sure you changes are in the current release branch and you don't need to create any side local branch I will create it for you :)";
  print_divider "star";
  echo "Okay so, Before we start, I Would need some inputs from you, So I can create PRs for you :)";
};

preprocess() {
  CURRENT_BRANCH=$(git branch --show-current 2>&1);
  #git status -s | wc -l
  FILES_NAMES=$(git ls-files -m);
  FILES_COUNT=$(git ls-files -m | wc -l);
  
  if [ $FILES_COUNT == "0" ]; then
        ExitProcess 1;
  fi
}

ExitProcess() {
  if [ $1 -eq 1 ]; then
    echo "Exiting with error code 1: No MODIFIED FILES FOUND TO COMMIT."
    exit 1;
  fi
  exit;
}

unset_input_variables() {
  unset CURRENT_BRANCH FILES_COUNT FILES_NAMES FILES ISSUE_ID MODULE_NAME COMMIT_MESSAGE PR_DESSCRIPTION PR_TITLE PR_MODE;
}

input_validation() {
  if [ ${FILES^^} != "ALL" ]; then
    FILES_NAMES=$FILES;
  fi
};

print_divider() {
  if [ $1 == "single_line" ]; then
    echo "---------------------------------------------------------------------------------------------------------";
  elif [ $1 == "double_double" ]; then 
    echo "========================================================================================================";
  elif [ $1 == "star" ]; then
    echo "*********************************************************************************************************";
  fi
}

receive_user_input() {
  print_divider single_line;
  echo "These are the List of Modified Files I could find:-";
  git ls-files -m;
  
  print_divider single_line;
  read -p "Provide the files from above list (including path) that you want me to commit OR type 'ALL' to select all files. For multiple please separate with space: " FILES;
  
  print_divider single_line;
  read -p "Provide your Module name - ap/ar/gl/igc/: " MODULE_NAME;
    
  print_divider single_line;
  read -p "Provide a valid TM/JIRA ID for this fix: " ISSUE_ID;

  print_divider single_line;
  read -p "Name the other remote branches (space separated) you want to create PR for: " REMOTE_BRANCHES;
    
  print_divider single_line;
  read -p "Provide a proper commit message: " COMMIT_MESSAGE;
  
  print_divider single_line;
  read -p "Provide a title for your PR: " PR_TITLE;
  
  print_divider single_line;
  read -p "Provide a description for your PR: " PR_DESSCRIPTION;

  print_divider single_line;
  read -p "Do you want to create PR in draft Mode (Y/N)? : " PR_MODE;
  
};

create_pull_request() {
#    echo "Files: $FILES";
#    echo "Module name: $MODULE_NAME";
#    echo "Files name: $FILES_NAMES";
#    echo "issue_id: $ISSUE_ID";
#    echo "remote branch: $REMOTE_BRANCHES";
#    echo "Commit msg: $COMMIT_MESSAGE";
#    echo "Pr title: $PR_TITLE";
#    echo "PR desc: $PR_DESSCRIPTION";
#    echo "Mode: $PR_MODE";
#    exit ;
    
  # use to exit when the command exits with a non-zero status.
  set -e;
  
  # echo commands as they are executed.
  #  set -x;

  #You can redirect stdout to /dev/null.
  #  yum install nano > /dev/null

  #Or you can redirect both stdout and stderr,
  #yum install nano &> /dev/null
  
  # Commit changes to hotfix branch and create a PR.
  {
    git checkout -b hotfix/nov22/$MODULE_NAME/$ISSUE_ID;
    git add $FILES_NAMES;
    git commit -m "$COMMIT_MESSAGE";
    COMMIT_ID=$(git rev-parse HEAD);
    git push --set-upstream origin hotfix/nov22/$MODULE_NAME/$ISSUE_ID;
    gh pr create --base nov22 --head hotfix/nov22/$MODULE_NAME/$ISSUE_ID --title "$PR_TITLE" --body "$PR_DESSCRIPTION" --assignee "@me" --draft; 
    
    # Loop over the other remote branches and cherry-pick the commit and create PR.
    for branch in $REMOTE_BRANCHES ; do
      echo $branch;
      git fetch origin;
      git checkout $branch;
      git pull origin $branch;
      git checkout -b fix/$branch/$MODULE_NAME/$ISSUE_ID;
      git cherry-pick $COMMIT_ID;
      git push origin fix/$branch/$MODULE_NAME/$ISSUE_ID;
      gh pr create --base "$branch" --head "fix/$branch/$MODULE_NAME/$ISSUE_ID" --title "$PR_TITLE" --body "$PR_DESSCRIPTION" --assignee "@me" --draft; 
    done
  } > /dev/null;
};

preprocess;
greet;
receive_user_input;
input_validation;
#echo "Just relax and Grab a Cup of coffeee/Teaaa...I am creating PR for you ;)";
create_pull_request;
# list created PR with gh pr list