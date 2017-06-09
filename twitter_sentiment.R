#load libraries
library(twitteR)
library(readr)

library(tm)
library(wordcloud)

library(caret)
library(RTextTools)

# AUTHORIZATION
# access authorization keys from twitter 
twitter_auth <-read.csv('data/twitter_auth.csv')
setup_twitter_oauth(twitter_auth$api_key, twitter_auth$api_secret, twitter_auth$access_token, twitter_auth$access_token_secret)


# SEARCH TWITTER
#Trend locations
trends <-availableTrendLocations()

#Getting trend in the wordl (woeid -> 1)
worldTrend <-getTrends(1)

#view trend limit
rateLimit <-getCurRateLimitInfo()

#Getting  positive tweets
tweetsPos<- searchTwitter(':)+storm+exclude:retweets', n=3000, lang='en')
class(tweets)
positive_tweets <-twListToDF(tweetsPos)
positive_tweets <- subset(positive_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(positive_tweets, 'data/positiveTweetsStorm.csv')

#Getting  negative tweets
tweetsNeg<- searchTwitter(':(+storm+exclude:retweets', n=3000, lang='en')
negative_tweets <-twListToDF(tweetsNeg)
negative_tweets <- subset(negative_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(negative_tweets, 'data/negativeTweetsStorm.csv')


# --CLEANING TWEETS--

#extract text from tweets
positive_tweets <- positive_tweets["text"]
negative_tweets <- negative_tweets["text"]

all_tweets <-c(positive_tweets$text, negative_tweets$text)

cleanTweets <- function(tweets){
  #remove emoticons
  clean_tweets <- gsub("[:;=B](')*(-)*[)(P3DSO*sp]+", "", tweets)
  #remove hashtags 
  clean_tweets <- gsub("#\\w+", "", clean_tweets)
  # remove links
  clean_tweets <- gsub("https?:\\/\\/.*[\\r\\n]*", "", clean_tweets)
  # remove @People
  clean_tweets = gsub("@\\w+", "", clean_tweets)
  # remove punctations symbols
  clean_tweets <- gsub("[[:punct:]]", "", clean_tweets)
  # remove numbers
  clean_tweets <- gsub("[[:digit:]]", "", clean_tweets)
  # remove line breaks
  clean_tweets <- gsub("\r?\n|\r", " ", clean_tweets)

  clean_tweets <- iconv(clean_tweets, "UTF-8", "ASCII", sub = "")
  #remove query word
  clean_tweets <- gsub("storm", "", tolower(clean_tweets))
  # remove leading whitespaces
  clean_tweets <- gsub("^[[:space:]]*","", clean_tweets) 
  # remove trailing whitespaces
  clean_tweets <- gsub("[[:space:]]*$","", clean_tweets)
  # remove extra whitespaces
  clean_tweets <- gsub(' +', ' ',clean_tweets) 
  #remove duplicates
  clean_tweets <- unique(clean_tweets)
  return(clean_tweets)
}

pos_tweets_clean <- cleanTweets(positive_tweets$text)
neg_tweets_clean <- cleanTweets(negative_tweets$text)
all_tweets_clean <- c(pos_tweets_clean, neg_tweets_clean)


# create dataframe from clean tweets with class column 
nrows_pos <- length(pos_tweets_clean)
nrows_neg <- length(neg_tweets_clean)
label_vec <- c(rep("pos",  nrows_pos), rep.int("neg", nrows_neg))
clean_tweets_df <- data.frame(text = all_tweets_clean, class = label_vec, stringsAsFactors = FALSE)

#write processed tweets to csv file
write_excel_csv(clean_tweets_df, 'data/cleanTweetsStorm.csv')


findFreqWords <- function(tweets){
  text_corpus <- VCorpus(VectorSource(tweets))
  #create term-document matrix
  tdm <- TermDocumentMatrix(text_corpus)
  m <- as.matrix(tdm)
  #sort words based on their frequences
  v <- sort(rowSums(m),decreasing=TRUE)
  df <- data.frame(word = names(v),freq=v)
  return (df)
}

word_frequence <- findFreqWords(all_tweets_clean)

createWordCloud <-function(text_corpus){
  
  wordcloud(text_corpus, scale=c(3,0.2), max.words=100, random.order=FALSE, 
            rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
  
}

createAndCleanCorpus <-function(tweets){
  
  #create a corpus from character vectors
  text_corpus = VCorpus(VectorSource(tweets))
  
  # -TRANSFORMATIONS-
  #remove words stopwords
  clean_corpus <- text_corpus %>% 
    tm_map(removeWords, c(stopwords("english"))) %>% 
    #eliminate extra whitespaces
    tm_map(stripWhitespace)
  return (clean_corpus)
  
}

clean_corpus_pos <- createAndCleanCorpus(pos_tweets_clean)
createWordCloud(clean_corpus_pos)

clean_corpus_neg <- createAndCleanCorpus(neg_tweets_clean)
createWordCloud(clean_corpus_neg)


#randomize the dataset
set.seed(1)
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]

clean_tweets_df$class <- as.factor(clean_tweets_df$class)

# create and clean up the corpus
clean_corpus <-createAndCleanCorpus(clean_tweets_df$text)

# create Document-Term matrix
dtm <- DocumentTermMatrix(clean_corpus)

# --FEATURE SELECTION--
freq <- findFreqTerms(dtm, 5)
length((freq))

# create Document-Term matrix
dtm2<- DocumentTermMatrix(clean_corpus, control=list(dictionary = freq))

# function to convert the word frequencies to yes (presence) and no (absence) labels
convert_count <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}

# apply the convert_count function to get final DTM
dtm2 <- apply(dtm2, 2, convert_count)


# NAIVE BAYES


# Train NB classifier using caret package with 10-fold cross validation 
control <- trainControl(method="cv", 10)
set.seed(2)
modelNB <- train(dtm2, clean_tweets_df$class, method="nb", trControl=control)
modelNB

#Naive Bayes 


# 1186 samples
# 325 predictor
# 2 classes: 'neg', 'pos' 

# No pre-processing
# Resampling: Cross-Validated (10 fold) 
# Summary of sample sizes: 1068, 1067, 1068, 1068, 1067, 1067, ... 
# Resampling results across tuning parameters:
  
#  usekernel  Accuracy   Kappa    
# FALSE      0.7723401  0.2877262
# TRUE       0.7723401  0.2877262

# Tuning parameter 'fL' was held constant at a value of 0
# Tuning parameter 'adjust' was held
# constant at a value of 1
# Accuracy was used to select the optimal model using  the largest value.
# The final values used for the model were fL = 0, usekernel = FALSE and adjust = 1.
 

# MAX ENTROPY
# create and train Max Entropy model
container <-create_container(dtm, as.numeric(clean_tweets_df$class), trainSize = 1:880, 
                             testSize = 881:1186, virgin = FALSE)  

# 10-folds cross validation
cross_validate(container, 10, "MAXENT")

# $meanAccuracy
#[1] 0.9204108



# SUPORT VECTOR MACHINES

modelSVM <- train(dtm, clean_tweets_df$class, method="svmLinear", trControl=control)
modelSVM

# Support Vector Machines with Linear Kernel 

# No pre-processing
# Resampling: Cross-Validated (10 fold) 
# Summary of sample sizes: 1067, 1068, 1067, 1068, 1067, 1067, ... 
# Resampling results:
  
#  Accuracy   Kappa    
# 0.7597422  0.2480407

# Tuning parameter 'C' was held constant at a value of 1





