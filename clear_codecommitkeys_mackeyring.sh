#!/bin/bash
# Remove up to 20 aws codecommit keys from the mac keyring
# It automates step 3.3 in https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html
# I suggest to add it to cron for each region you use.
REGION=$1 # i.e. eu-west-1
KEYCHAIN="/Users/mattialambertini/Library/Keychains/login.keychain-db"

for run in {0..20}
do
  OUTPUT=$( { security delete-internet-password -l "git-codecommit.${REGION}.amazonaws.com" $KEYCHAIN; } 2>&1 )
  if [[ $OUTPUT == *"The specified item could not be found in the keychain"* ]]; then
    echo "Deleted $run passwords"
    exit 0
  fi
done
