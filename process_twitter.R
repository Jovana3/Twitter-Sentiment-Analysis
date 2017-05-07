# --CLEANING TWEETS--
 
#extract text from tweets
positive_tweets <- positive_tweets["text"]
negative_tweets <- negative_tweets["text"]

all_tweets <-c(positive_tweets$text, negative_tweets$text)

cleanTweets <- function(tweets){
  #remove retweet entities
  clean_tweets <- gsub("(RT|via)((?:\\b\\W*@\\w+)+:)", "", tweets) 
  #remove @People
  clean_tweets = gsub("@\\w+", "", clean_tweets) 
  #remove punctations symbols
  clean_tweets <- gsub("[[:punct:]]", "", clean_tweets)
  # remove numbers
  clean_tweets <- gsub("[[:digit:]]", "", clean_tweets)
  #remove links
  clean_tweets <- gsub("http\\w+", "", clean_tweets) 
  #remove line breaks
  clean_tweets <- gsub("\r?\n|\r", " ", clean_tweets)
  
  clean_tweets <- iconv(clean_tweets, "UTF-8", "ASCII", sub = "")
  #remove query word
  clean_tweets <- gsub("russiangp", "", tolower(clean_tweets))
  #remove duplicates
  clean_tweets <- unique(clean_tweets)
  return(clean_tweets)
}

pos_tweets_clean <- cleanTweets(positive_tweets$text)
neg_tweets_clean <- cleanTweets(negative_tweets$text)
all_tweets_clean <- c(pos_tweets_clean, neg_tweets_clean)

#create dataframe from clean tweets with class column 
nrows_pos <- length(pos_tweets_clean)
nrows_neg <- length(neg_tweets_clean)
label_vec <- c(rep("pos",  nrows_pos), rep.int("neg", nrows_neg))
clean_tweets_df <- data.frame(text = all_tweets_clean, class = label_vec, stringsAsFactors = FALSE)

#write processed tweets to csv file
write_excel_csv(clean_tweets_df, 'cleanTweets.csv')




