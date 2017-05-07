library(tm)
library(wordcloud)
library(magrittr)

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



