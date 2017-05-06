#load libraries
library(twitteR)
library(readr)

#Trend locations
trends <-availableTrendLocations()

#Getting trend in the wordl (woeid -> 1)
worldTrend <-getTrends(1)

#view trend limit
rateLimit <-getCurRateLimitInfo()

#Getting  positive tweets
tweets <- searchTwitter('#RussianGP :)', n=10000, lang='en')
class(tweets)
positive_tweets <-twListToDF(tweets)
positive_tweets <- subset(positive_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(positive_tweets, 'positiveTweets.csv')

#Getting  negative tweets
tweets2 <- searchTwitter('#RussianGP :(', n=10000, lang='en')
negative_tweets <-twListToDF(tweets2)
negative_tweets <- subset(negative_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(negative_tweets, 'negativeTweets.csv')





