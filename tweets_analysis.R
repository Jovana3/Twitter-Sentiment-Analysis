library(tm)
library(wordcloud)

findFreqWords <- function(tweets){
  text_corpus = VCorpus(VectorSource(tweets))
  #create term-document matrix
  tdm <- TermDocumentMatrix(text_corpus)
  m <- as.matrix(tdm)
  #sor words based on their frequences
  v <- sort(rowSums(m),decreasing=TRUE)
  return (v)
}


createWordCloud <-function(tweets){

  #create a corpus from character vectors
  text_corpus = VCorpus(VectorSource(tweets))
  #creeate vector of irrelevant words 
  words <- c("f", "russia", "russiangrandprix", "russiangp", "russian", "grand","prix")

  # -TRANSFORMATIONS-
  #remove words stopwords and irrelevant words
  text_corpus = tm_map(text_corpus, removeWords, c(stopwords("english"), words))
  #eliminate extra whitespaces
  text_corpus = tm_map(text_corpus, stripWhitespace)
  
  wordcloud(text_corpus, scale=c(4,0.5), max.words=100, random.order=FALSE, 
          rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
  
}

createWordCloud(pos_tweets_clean)
createWordCloud(neg_tweets_clean)
