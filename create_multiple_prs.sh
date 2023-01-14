#!/bin/sh

#use to exit when the command exits with a non-zero status.
#set -e

declare CURRENT_BRANCH FILES_COUNT FILES_NAMES FILES ISSUE_ID MODULE_NAME COMMIT_MESSAGE PR_DESSCRIPTION PR_TITLE PR_MODE;

greet() {
  print_divider "double_double";
  echo "Hello! Welcome to the Automation Universe";
  echo "I Would need some inputs from you, So I can create PRs for you :)";
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
    echo "-------------------------------------------------------------------------------------------------";
  elif [ $1 == "double_double" ]; then 
    echo "=================================================================================================";
  fi
}

receive_user_input() {
  print_divider single_line;
  echo "PROVIDE ALL THE FILES FROM ABOVE LIST (INCLUDING PATH) THAT YOU WANT TO COMMIT";
  echo 'OR TYPE "ALL" TO SELECT ALL FILES.'
  echo "MULTIPLE FILES NEED TO BE SPACE SEPARATED"
  read FILES;
  
  print_divider single_line;
  echo "PROVIDE A VALID TM/JIRA ID.";
  read ISSUE_ID;

  print_divider single_line;
  echo "PROVIDE YOUR MODULE NAME - AP/AR/GL/IGC/.";
  read MODULE_NAME;

  print_divider single_line;
  echo "Provide A PROPER COMMIT MESSAGE."
  read COMMIT_MESSAGE;


  print_divider single_line;
  echo "Provide A DESSCRIPTION TO YOUR PR";
  read PR_DESSCRIPTION;

  print_divider single_line;
  echo "Provide A TITLE TO YOUR PR";
  read PR_TITLE;

  print_divider single_line;
  echo "DO YOU WANT TO CREATE PR IN DRAFT MODE (Y/N)?";
  read PR_MODE;
};

create_pull_request() {
  BASE_BRANCH=master;
  PR_BRANCH=hotfix/nov22/$MODULE_NAME/$ISSUE_ID;
  status = $(
  set -e;
  git checkout -b $PR_BRANCH;
  git add $FILES_NAMES;
  git commit -m $COMMIT_MESSAGE;
  git push --set-upstream origin $PR_BRANCH;
  gh pr create --base "$BASE_BRANCH" --head "$PR_BRANCH" --title "$PR_TITLE" --body "$PR_DESSCRIPTION" --assignee "@me" --draft; 
  );
};

preprocess;
#greet;
receive_user_input;
input_validation;
create_pull_request;
#echo "Just relax and Grab a Cup of coffeee/Teaaa...I am creating PR for you ;)";