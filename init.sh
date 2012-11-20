#!/bin/bash
#This script sets up Heroku + your local environment for Twitter

echo "First, let's create a Heroku app for this bot."
echo -n "What shall we call this thing, then? "
read botname

while ! heroku create --stack cedar $botname; do
    echo "We failed to create the Heroku app"
    echo -n "How about we try another name? "
    read botname
done
#Heroku app has now been successfully created

echo
echo "We're going to need some Twitter API credentials."
echo "Check out https://dev.twitter.com/docs/auth/tokens-devtwittercom"
echo "for instructions on creating your Consumer Key and Access Token."
echo "Be sure to set to Access Level to \"Read and write\" in the Settings tab."
echo

confirmed_creds="n"
while [ $confirmed_creds != "y" ]; do

    echo -n "Consumer key: "
    read consumerkey
    echo -n "Consumer secret: "
    read consumersecret
    echo -n "Access token: "
    read accesstoken
    echo -n "Access token secret: "
    read accesstokensecret

    echo "We read these credentials:"
    cat <<EOF
TWITTER_CONSUMER_KEY=$consumerkey
TWITTER_CONSUMER_SECRET=$consumersecret
TWITTER_ACCESS_TOKEN=$accesstoken
TWITTER_ACCESS_TOKEN_SECRET=$accesstokensecret
EOF
    echo "Is this correct? [y/n]"
    read confirmed_creds
done



#add the twitter credentials to the Heroku app environment
echo
echo "Sending your Twitter API credentials up to Heroku..."
heroku config:add TWITTER_CONSUMER_KEY=$consumerkey \
    TWITTER_CONSUMER_SECRET=$consumersecret \
    TWITTER_ACCESS_TOKEN=$accesstoken \
    TWITTER_ACCESS_TOKEN_SECRET=$accesstokensecret

#create a script for setting up your local environment
cat <<EOF > setup_env.sh
export TWITTER_CONSUMER_KEY=$consumerkey
export TWITTER_CONSUMER_SECRET=$consumersecret
export TWITTER_ACCESS_TOKEN=$accesstoken
export TWITTER_ACCESS_TOKEN_SECRET=$accesstokensecret
EOF

echo
echo "Pushing to Heroku so that we can set up worker process"
git push heroku master
#Now Heroku should recognize worker when we try to scale

echo
echo "Scaling to worker=1"
heroku ps:scale worker=1

echo "Now you can \"source setup_env.sh\" and get to work on that sweet bot!"
