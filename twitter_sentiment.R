#load libraries
library(twitteR)
library(readr)

library(dplyr)
library(e1071)
library(caret)
library(pander)

library(tm)
library(wordcloud)
library(magrittr)
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
tweets <- searchTwitter('#RussianGP :)', n=10000, lang='en')
class(tweets)
positive_tweets <-twListToDF(tweets)
positive_tweets <- subset(positive_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(positive_tweets, 'data/positiveTweets.csv')

#Getting  negative tweets
tweets2 <- searchTwitter('#RussianGP :(', n=10000, lang='en')
negative_tweets <-twListToDF(tweets2)
negative_tweets <- subset(negative_tweets, select=c("created", "id", "text", "screenName", "retweetCount"))

#write tweets to cvs file
write_excel_csv(negative_tweets, 'data/negativeTweets.csv')


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
write_excel_csv(clean_tweets_df, 'data/cleanTweets.csv')


findFreqWords <- function(tweets){
  text_corpus = VCorpus(VectorSource(tweets))
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
  
  wordcloud(text_corpus, scale=c(4,0.5), max.words=100, random.order=FALSE, 
            rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
  
}

createAndCleanCorpus <-function(tweets){
  
  #create a corpus from character vectors
  text_corpus = VCorpus(VectorSource(tweets))
  #creeate vector of irrelevant words 
  irr_words <- c("f", "russia", "russiangrandprix", "russiangp", "russian", "grand","prix")
  
  # -TRANSFORMATIONS-
  #remove words stopwords and irrelevant words
  clean_corpus <- text_corpus %>% 
    tm_map(removeWords, c(stopwords("english"), irr_words)) %>% 
    #eliminate extra whitespaces
    tm_map(stripWhitespace)
  return (clean_corpus)
  
}

clean_corpus_pos <- createAndCleanCorpus(pos_tweets_clean)
createWordCloud(clean_corpus_pos)

clean_corpus_neg <- createAndCleanCorpus(neg_tweets_clean)
createWordCloud(clean_corpus_neg)


# NAIVE BAYES

#randomize the dataset
set.seed(1)
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]

clean_tweets_df$class <- as.factor(clean_tweets_df$class)

# create and clean up the corpus
clean_corpus <-createAndCleanCorpus(clean_tweets_df$text)

# create Document-Term matrix
dtm <- DocumentTermMatrix(clean_corpus)

#partitioning the data for training and testing purposes
train_index <- createDataPartition(clean_tweets_df$class, p=0.80, list=FALSE)

df_train <- clean_tweets_df[train_index,]
df_test <- clean_tweets_df[-train_index,]

dtm_train <- dtm[train_index,]
dtm_test <- dtm[-train_index,]

clean_corpus_train <- clean_corpus[train_index]
clean_corpus_test <- clean_corpus[-train_index]

# a utility function for % freq tables
frqtab <- function(x, caption) {
  round(100*prop.table(table(x)), 1)
}

# making sure that procedure keeps the proportions 
orig <- frqtab(clean_tweets_df$class)
train <- frqtab(df_train$class)
test <- frqtab(df_test$class)
df <- as.data.frame(cbind(orig, train, test))
colnames(df) <- c("Original", "Training set", "Test set")
pander(df, style="rmarkdown",caption=paste0("Comparison of sentiment class frequencies among datasets"))


# --FEATURE SELECTION--
freq <- findFreqTerms(dtm_train, 50)
length((freq))

dtm_train_nb <- DocumentTermMatrix(clean_corpus_train, control=list(dictionary = freq))
dim(dtm_train_nb)

dtm_test_nb <- DocumentTermMatrix(clean_corpus_test, control=list(dictionary = freq))
dim(dtm_test_nb)

# function to convert the word frequencies to yes (presence) and no (absence) labels
convert_count <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}

# apply the convert_count function to get final training and testing DTMs
trainNB <- apply(dtm_train_nb, 2, convert_count)
testNB <- apply(dtm_test_nb, 2, convert_count)

# train the  Naive Bayes classifier
system.time(classifierNB <- naiveBayes(trainNB, df_train$class, laplace = 1))

# use the NB classifier we built to make predictions on the test set.
system.time(prediction <- predict(classifierNB, newdata=testNB))

# create a table by tabulating the predicted class labels with the actual class labels
table("Predictions"= prediction,  "Actual" = df_test$class )

# prepare the confusion matrix
conf_mat <- confusionMatrix(prediction, df_test$class)

# prediction Accuracy
conf_mat$overall['Accuracy']
# 0.4232  

# Train NB classifier using caret package with 10-fold cross validation 
control <- trainControl(method="cv", 10)
set.seed(2)
modelNB <- train(trainNB, df_train$class, method="nb", trControl=control)
modelNB

# Naive Bayes 

# 6888 samples
# 264 predictor
# 2 classes: 'neg', 'pos' 

# No pre-processing
# Resampling: Cross-Validated (10 fold) 
# Summary of sample sizes: 6200, 6198, 6199, 6200, 6199, 6199, ... 
# Resampling results across tuning parameters:

# usekernel  Accuracy   Kappa     
# FALSE      0.4464215  -0.1071566
# TRUE      0.4464215  -0.1071566


# Testing the predictions
predictNB <- predict(modelNB, testNB)
cm <- confusionMatrix(predictNB, df_test$class, positive="pos")
cm

# Confusion Matrix and Statistics

# Reference
# Prediction neg pos
# neg 502 695
# pos 644 453

# Accuracy : 0.4163   


# MAX ENTROPY


# Create the Document-term matrix using freq terms created earlier
dtm <-DocumentTermMatrix(clean_corpus, control = list(dictionary = freq))
dim(dtm)

# create and train Max Entropy model
container <-create_container(dtm, as.numeric(clean_tweets_df$class), trainSize = 1:6888, 
                             testSize = 6889:9182, virgin = FALSE)  

MAXENTmodel <- train_model(container, "MAXENT")
result <- classify_model(container, MAXENTmodel)
analytics <- create_analytics(container, result)
summary(analytics)

#ALGORITHM PERFORMANCE

# MAXENTROPY_PRECISION    MAXENTROPY_RECALL    MAXENTROPY_FSCORE 
#                0.440                0.440                0.435  
# 10-folds cross validation
cross_validate(container, 10, "MAXENT")


# $meanAccuracy
# [1] 0.5082098


# SUPORT VECTOR MACHINES


# Create the Document-term matrix using freq terms created earlier
dtm <-DocumentTermMatrix(clean_corpus, control = list(dictionary = freq))
dim(dtm)

# create and train SVM model
container <-create_container(dtm, as.numeric(clean_tweets_df$class), trainSize = 1:6888, 
                             testSize = 6889:9182, virgin = FALSE)  

SVMmodel <- train_model(container, "SVM")
result <- classify_model(container, SVMmodel)
analytics <- create_analytics(container, result)
summary(analytics)

#ALGORITHM PERFORMANCE

#SVM_PRECISION    SVM_RECALL    SVM_FSCORE 
#         0.58          0.58          0.58

# 10-folds cross validation
cross_validate(container, 10, "SVM")

#$meanAccuracy
#[1] 0.3695708





