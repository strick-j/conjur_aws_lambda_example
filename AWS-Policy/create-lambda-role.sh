#!/bin/bash

function main(){
  gather_info
  create_role
}

sys_read(){
  done=0
  while : ; do
    read -p "$1 " userAnswer
    read -p "You entered $userAnswer, is this correct [Yes]: " checkAnswer
    checkAnswer=${checkAnswer:-Yes}
    case "$checkAnswer" in
      Yes | yes)
        done=1
        printf "Answer confirmed, continuing...\n\n"
        ;;
      No | no)
        printf "Please try again.\n\n" 
        ;;
      *)
        printf "Invalid response, options are Yes or No. Please try again\n\n"
        ;;
    esac    
    if [[ "$done" -ne 0 ]]; then
      break
    fi
  done
}

# Gather required info - rolename, policy docs, instance profile name
gather_info(){
  printf "\n==== Gathering Prerequisite Information =======\n"
  sys_read "1. Please enter an AWS Role Name:"
  roleName=$userAnswer
  
  sys_read "2. Please enter an AWS Instance Profile Name:"
  instanceProfileName=$userAnswer
  
  trustPolicy=lambda-trust-policy.json
  permissionsPolicy=lambda-permissions-policy.json

  # Recap information
  printf "Note: Using the following information to create AWS Policy:"
  printf "\n  - Role Name: \e[1m$roleName\e[0m"
  printf "\n  - Instance Profile Name: \e[1m$instanceProfileName\e[0m"
  printf "\n  - Trust Policy Document: \e[1m$trustPolicy\e[0m"
  printf "\n  - Permissions Policy Document: \e[1m$permissionsPolicy\e[0m\n"
}

# Create role based on gatherd info - 
create_role(){
  printf "\n==== Step 1: Creating Initial Role =============\n"
  aws iam create-role --role-name $roleName --assume-role-policy-document file://$trustPolicy
  printf "\n==== Step 1: Role Created ======================\n"
  printf "\n==== Step 2: Adding Permissions to role ========\n"
  aws iam put-role-policy --role-name $roleName  --policy-name Permissions-Policy-For-$roleName --policy-document file://$permissionsPolicy
  printf "\n==== Step 2: Permissions Policy Added ===========\n"
  printf "\n==== Step 3: Creating Instance Profile ==========\n"
  aws iam create-instance-profile --instance-profile-name $instanceProfileName
  printf "\n==== Step 3: Instance Profile Created ===========\n"
  printf "\n==== Step 4: Adding Instance Profile to Role ====\n"
  aws iam add-role-to-instance-profile --instance-profile-name $instanceProfileName --role-name $roleName
  printf "\n==== Step 4: Instance Profile Added to Role =====\n"
}

main

