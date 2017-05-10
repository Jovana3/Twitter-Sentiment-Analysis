library(dplyr)
library(e1071)
library(caret)
library(pander)

#randomize the dataset
set.seed(1)
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]
clean_tweets_df <- clean_tweets_df[sample(nrow(clean_tweets_df)), ]

clean_tweets_df$class <- as.factor(clean_tweets_df$class)

#create and clean up the corpus
clean_corpus <-createAndCleanCorpus(clean_tweets_df$text)

dtm <- DocumentTermMatrix(clean_corpus)

#partitioning the data for training and testing purposes

train_index <- createDataPartition(clean_tweets_df$class, p=0.75, list=FALSE)

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
freq <- findFreqTerms(dtm_train, 35)
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
mySVM <- svm(df_train, df_train$class)

# use the NB classifier we built to make predictions on the test set.
system.time(prediction <- predict(classifierNB, newdata=testNB))

# create a table by tabulating the predicted class labels with the actual class labels
table("Predictions"= prediction,  "Actual" = df_test$class )

# prepare the confusion matrix
conf_mat <- confusionMatrix(prediction, df_test$class)

# prediction Accuracy
conf_mat$overall['Accuracy']

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


