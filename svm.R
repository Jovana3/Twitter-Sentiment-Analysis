library(RTextTools)

# Create the Document-term matrix using freq terms created earlier
dtm <-DocumentTermMatrix(clean_corpus, control = list(dictionary = freq))
dim(dtm)

# create and train SVM model
container <-create_container(dtmAll, as.numeric(clean_tweets_df$class), trainSize = 1:7000, 
                             testSize = 7001:9182, virgin = FALSE)  

SVMmodel <- train_model(container, "SVM")
result <- classify_model(container, SVMmodel)
analytics <- create_analytics(container, result)
summary(analytics)

#ALGORITHM PERFORMANCE

#SVM_PRECISION    SVM_RECALL    SVM_FSCORE 
#        0.605         0.600         0.600

# 10-folds cross validation
cross_validate(container, 10, "SVM")

#$meanAccuracy
#[1] 0.3695708

