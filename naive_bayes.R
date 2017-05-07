library(dplyr)
library(e1071)
library(caret)

#randomize the dataset
set.seed(1)
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]

clean_tweets_df$class <- as.factor(clean_tweets_df$class)

#create and clean up the corpus
clean_corpus <-createAndCleanCorpus(clean_tweets_df$text)

dtm <- DocumentTermMatrix(clean_corpus)

#partitioning the data for training and testing purposes
df_train <- clean_tweets_df[1:7500,]
df_test <- clean_tweets_df[7501:9182,]

dtm_train <- dtm[1:7500,]
dtm_test <- dtm[7501:9182,]

clean_corpus_train <- clean_corpus[1:7500]
clean_corpus_test <- clean_corpus[7501:9182]

# --FEATURE SELECTION--
freq <- findFreqTerms(dtm_train, 35)
length((freq))

dtm_train_nb <- DocumentTermMatrix(clean_corpus_train, control=list(dictionary = freq))
dim(dtm_train_nb)
# 7500 264

dtm_test_nb <- DocumentTermMatrix(clean_corpus_test, control=list(dictionary = freq))
dim(dtm_test_nb)
# 1682 264

#function to convert the word frequencies to yes (presence) and no (absence) labels
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

