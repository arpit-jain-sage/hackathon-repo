#!/bin/sh

CURRENT_BRANCH,NUM_FILES,FILES,ISSUE_ID,MODULE_NAME,COMMIT_MESSAGE,PR_DESSCRIPTION, PR_TITLE, PR_MODE
echo "=========================================================================================================";
#echo "NOTE: MAKE SURE YOU ARE IN RELEASE BRANCH AND YOUR LOCAL BRANCH IS UPTO DATE WITH REMOTE BRANCH OTHERWISE RUN BELOW COMMANDS FIRST:-"
#echo "git checkout Nov22; git fetch origin Nov22; git pull origin --prune";
CURRENT_BRANCH=$(git branch --show-current 2>&1);
echo "YOU ARE CURRENTLY IN ${CURRENT_BRANCH} BRANCH.";
echo "GETTING LIST OF ALL THE MODIFIED FILES...";
#git ls-files -m;
git status -s;
NUM_FILES=$(git status -s | wc -l);
if [ $NUM_FILES -eq 0 ]; then
    echo "NO FILES TO COMMIT. \n";
    exit;
fi

echo "-------------------------------------------------------------------------------------------------";
echo "THIS WILL CREATE BELOW BRANCH";
echo "hotfix/nov22/igc/{$ISSUE_ID}"
#echo "SPECIFY A BRANCH NAME YOU WANT TO CREATE."
#read $branch_name;
echo "-------------------------------------------------------------------------------------------------";

receive_user_input() {
  print_divider single;
  echo "PROVIDE ALL THE FILES FROM ABOVE LIST (INCLUDING PATH) THAT YOU WANT TO COMMIT";
  echo 'OR TYPE "ALL" TO SELECT ALL FILES.'
  echo "MULTIPLE FILES NEED TO BE COMMA SEPARATED"
  read $FILES;
  
  print_divider single;
  echo "PROVIDE A VALID TM/JIRA ID.";
  read $ISSUE_ID;
  
  print_divider single;
  echo "PROVIDE YOUR MODULE NAME - AP/AR/GL/IGC/.";
  read $MODULE_NAME;
  
  print_divider single;
  echo "Provide A PROPER COMMIT MESSAGE."
  read $COMMIT_MESSAGE;
  
  print_divider single;
  echo "Provide A PROPER COMMIT MESSAGE."
  read $COMMIT_MESSAGE;
  
  print_divider single;
  echo "Provide A DESSCRIPTION TO YOUR PR";
  read $PR_DESSCRIPTION;
  
  print_divider single;
  echo "Provide A TITLE TO YOUR PR";
  read $PR_TITLE;
  
  print_divider single;
  echo "DO YOU WANT TO CREATE PR IN DRAFT MODE (Y/N)?";
  read $PR_MODE;
  
};
unset_input_variables() {
  unset CURRENT_BRANCH NUM_FILES FILES ISSUE_ID MODULE_NAME COMMIT_MESSAGE PR_DESSCRIPTION PR_TITLE PR_MODE;
}
print_divider() {
  if [ $1 == "single" ]; then
    echo "-------------------------------------------------------------------------------------------------";
  elif [ $1 == "double" ]; then 
    echo "=================================================================================================";
  fi
}


greet() {
  echo "Hello!, I Would need some inputs from you, So I can create PRs for you :)";
};
input_validation() {};
create_pull_request() { gh pr create --title $PR_TITLE --body $PR_DESSCRIPTION };

greet;
receive_user_input;
input_validation;
create_pull_request;

echo "Just relax and Grab a Cup of coffeee/Teaaa...I am creating PR for you ;)"