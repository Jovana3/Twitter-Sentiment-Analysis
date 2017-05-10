library(RTextTools)

# Create the Document-term matrix using freq terms created earlier
dtm <-DocumentTermMatrix(clean_corpus, control = list(dictionary = freq))
dim(dtm)

# create and train Max Entropy model
container <-create_container(dtm, as.numeric(clean_tweets_df$class), trainSize = 1:7000, 
                             testSize = 7001:9182, virgin = FALSE)  

MAXENTmodel <- train_model(container, "MAXENT")
result <- classify_model(container, MAXENTmodel)
analytics <- create_analytics(container, result)
summary(analytics)

#ALGORITHM PERFORMANCE

# MAXENTROPY_PRECISION    MAXENTROPY_RECALL    MAXENTROPY_FSCORE 
#                0.430                0.425                0.425 
# 10-folds cross validation
cross_validate(container, 10, "MAXENT")

# $meanAccuracy
# [1] 0.5108323