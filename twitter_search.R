#load libraries
library(twitteR)
library(readr)

#Trend locations
trends <-availableTrendLocations()


#Getting trend in the wordl (woeid -> 1)
worldTrend <-getTrends(1)

#view trend limit
rateLimit <-getCurRateLimitInfo()

#Getting tweets
tweets <- searchTwitter('#RussianGP :)', n=1000, lang='en')
class(tweets)
positive_tweets <-twListToDF(tweets)


#write tweets to cvs file
write_excel_csv(positive_tweets, 'positiveTweets.csv')
