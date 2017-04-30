# --CLEANING TWEETS--
 
#extract text from tweets
positive_tweets <- positive_tweets["text"]
negative_tweets <- negative_tweets["text"]

#labeling tweets (1-positive, 0-negative)
positive_tweets[ , "label"] <- rep.int(1, nrow(positive_tweets))
negative_tweets[ , "label"] <- rep.int(0, nrow(negative_tweets))

#remove duplicates
positive_tweets <- unique(positive_tweets)
negative_tweets <- unique(negative_tweets)

tweets <-c(positive_tweets$text, negative_tweets$text)

#remove retweet entities
clean_tweets <- gsub("(RT|via)((?:\\b\\W*@\\w+)+:)", "", tweets) 
#remove @People
clean_tweets = gsub("@\\w+", "", clean_tweets) 
#remove punctations symbols
clean_tweets = gsub("[[:punct:]]", "", clean_tweets)
# remove numbers
clean_tweets = gsub("[[:digit:]]", "", clean_tweets)
#remove links
clean_tweets = gsub("http\\w+", "", clean_tweets) 
#remove line breaks
clean_tweets = gsub("\r?\n|\r", " ", clean_tweets)

clean_tweets = iconv(clean_tweets, "UTF-8", "ASCII", sub = "")



