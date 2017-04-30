library(twitteR)

# access authorization keys from twitter 
twitter_auth <-read.csv('twitter_auth.csv')
setup_twitter_oauth(twitter_auth$ï..api_key, twitter_auth$api_secret, twitter_auth$access_token, twitter_auth$access_token_secret)
