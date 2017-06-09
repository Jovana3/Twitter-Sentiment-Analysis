# Twitter-Sentiment-Analysis

## Sadržaj 

Količina informacija koja protiče društvenim mrežama svakodnevno se povećava i predstavlja bogat izvor podataka koji, ako se pravilno semantički obradi, može biti veoma koristan u najrazličitijim oblastima. Cilj ovog projekta je analiza sentimenta Twitter poruka primenom algoritama mašinskog učenja. 

U radu su korišćeni sledeći algoritmi: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora. 

Osnovna ideja je prikupljanje tekstualnih podataka u cilju konstrukcije i evaluacije različitih klasifikatora za analizu sentimenta Twitter poruka. Dobijeni klasifikatori su testirani i međusobno upoređeni u cilju pronalaska onog koji pruža najbolje performance klasifikacije sentimenta Twitter poruka. 

## Uvod

Korišćenje Interneta kao komunikacionog kanala omogućilo je da društvene mreže i servisi za mikroblogovanje postanu značajan potencijalni izvor znanja koje se kasnijom semantičkom obradom i analizom mogu koristiti u procesima donošenja odluka.

Velika količina podataka koja se svakog dana generiše putem interneta pripada nestruktuiranim podacima tekstualnog tipa. Mašinsko učenje omogućava da sistem prepozna date reči i pripoji im neko smisleno značenje. 

Svakodnevni porast i prisutnost mobilnih uređaja u svakodnevnom životu, u velikoj meri su olakšali pristup društvenim mrežama, i pojednostavili način deljenja informacija jednim klikom. Mikroblogovanje kao jedan  od oblika društvenih mreža se već uveliko integrisao u svakodnevni život i postao deo svakodnevne komunikacije i razmene informacija. Smatra se da su podaci proizvedeni mikroblogovanjem nedvosmisleni, brzi i pristupačni. Twitter, kao najpoznatiji servis za mikrobloging, izuzetno je pogodan je za procenu stava ogromnog broja korisnika. 

Pored toga, podaci sa Twitter-a su posebno interesantni jer se poruke pojavljuju „brzinom misli“ odnosno dostupni su za preuzimanje momentalno, jer se sve odigrava u „skoro realnom vremenu“ (eng. *near real-time*).  

## Definicija anlalize sentimenta

Analiza sentimenta teksta obuhvata process određivanja emotivnog tona na osnovu niza reči, a koristi se kako bi se steklo razumevanje stava, mišljenja i emocija koji su izraženi u okviru teksta. U ovom radu korišćena je binarna klasifikacija Twitter poruka u dve klase: pozitivnu i negativnu.

Često može biti neodređeno da li određena twitter poruka sadrži emociju. Takve twitter poruke nazivamo neutralnim [2]. Međutim, u ovom radu neutralne poruke nisu uzete u razmatranje prilikom analize sentimenta.  

## Podaci

Za treniranje određenog klasifikatora, najčešće su potrebni ručno obeleženi podaci. Međutim sa velikim brojem tema koje su diskutovane na Twitter-u bilo bi teško prikupiti veliki broj twitter poruka koji je potreban za trening klasifikatora. Stoga, u ovom radu korišćena je automatska ekstrakcija osećenja iz Twitter poruka na osnovu emotikona. Na primer, emotikon :) ukazuje da se radi o poruci sa pozitivnom emocijom, dok emotikon :( ukazuje da je izražena negativna emocija [1].

### Prikupljanje podataka putem Twitter API servisa

Putem [Twitter API-ja](https://dev.twitter.com/rest/public) omogućen je pristup Twitter porukama koje su objavljene u poslednjih 7 dana. Takođe, moguće je pristupiti i podacima o geolokaciji svake Twitter poruke. Na taj način omogućeno e proučavanje kako tekstualnih tako i lokacijskih karakteristika online sadržaja. Upiti se šalju u obliku URL adrese i u sebi sadrže ključne reči pretrage i druge parametre. Postoje ograničenja sa serverske strane o broju upita, odnosno zahteva koje se mogu uputiti u minuti.

U ovom radu korišćen je Twitter Search API, koji za razliku od Stream API-ja poseduje određena ograničenja prilikom slanja upita i pretraživanja podataka. Upiti koji pretražuju tvitove mogu da vrate maksimalno do 100 tvitova po jednom upitu. Takođe kao što je već naglašeno, nije moguće pretraživati stare tvitove, već samo one objavljene u proteklih sedam dana.

Za komunikaciju sa Twitter API/jem korišćena je biblioteka *twitteR* za R programski jezik.

Za preuzimanje podataka putem Twitter API servisa možemo izdvojiti sledeće glavne korake:
•	Kreiranje i registrovanje Twitter aplikacije
•	Izbor ključne reči za pretragu 
•	Formiranje i izvršenje upita  

#### Kreiranje i registrovanje Twitter aplikacije

S obzirom da Twitter zahteva autorizaciju prilikom korišćenja svojih servisa, bilo je neophodno kreirati i registrovati Twitter aplikaciju. Postoji mogućnost i autorizacije bez aplikacije, ali su tada ograničenja veća, pa je zbog toga odlučeno  da se koristi OAuth 1 sistem autorizacije koji poseduje četiri parametra za pristup:  
•	API key  
•	API secret  
•	Access Token   
•	Access Token Secret  

Ovi parametri su trajni kada se jednom kreiraju, pa ih je moguće koristiti dok god postoji registrovana aplikacija. 
Nakon kreiranja aplikacije, preuzeti parametri su sačuvani dokumentu pod nazivom *twitter_auth.csv*.

```R
api_key, api_secret, access_token, access_token_secret
fUwSn9X71bJx7fdogjNkPISWK, ecKEBsuTcYqUzc2CevwKSQ7vxNbpKAcjO9hIkov8KBfq2WdYKN, 850259759039004674-acAlrgoJnk9T6JwUU9W1FaWcqvDrpI9, dMLzxOehsLFiIWVefQgNEiXvm101qzUem6JSDa7i3leco
```

Autorizacija je uspostavljenja korišćenjem raspoložive funkcije *setup_twitter_oauth()* kojoj su prosleđeni dati parametri. 

### Izbor ključne reči za pretragu

Biblioteka twitteR nudi mogućnost sagledavanja trenda, odnostno aktuelne teme za određeno geografsko područje. Funkcjia *availableTrendLocations()* vraća informacije o trenutno dostupnim lokacijama uz njihov *woeid* (where on Earth ID). 
Stoga, možemo koristiti funkciju *getTrends()* koja prikazuje trenutne trendove za specificirani woeid tražene lokacije. Ukoliko želimo pretragu za ceo svet, *woeid* iznosi 1. 

Radi kreiranja boljih klasifikatora, cilj je prikupiti što veći uzorak. Zbog toga ćemo najpre izvrštiti analizu trendova u celom svetu, prema objašnjenom postupku, kako bismo prikupili što veći broj Twitter poruka. 

#### Formiranje i izvršenje upita

Da bismo mogli da prikupimo podatke putem Twitter API servisa, neophodno je da ispoštujemo određen format upita koji servis zahteva. Za pretragu Twitter-a korišćena je raspoloživa funkcija *searchTwitter()*. Ukoliko želimo da izvršimo jednostavnu pretragu po nekoj ključnoj reči, dovoljno je da funkciji prosledimo datu ključnu reč. Za komplikovanije pretrage moguće je koristiti različite operatore kojima se može promeniti ponašenja upita. U sledećoj tabeli navedeni su neki od operatora koji su zajedno sa objašnjenim ponašanjem dostupni u Twitter Search API dokumentaciji. 

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/operators.png)

Funkcija *searchTwitter()* izvršava pretragu Twitter-a na osnovu prosleđenog stringa. Poseduje sledeću sintaksu:

```R
searchTwitter (searchString, n=25, lang=NULL, since=NULL, until=NULL, locale=NULL,  
              geocode=NULL, sinceID=NULL, maxID=NULL, resultType=NULL, retryOnRateLimit=120)
```

Kako bismo izvršili testiranje klasifikatora, neophodno je da pripremimo 2 oveležena dataset-a sa Twitter porukama gde je svaka od njih označena kao pozitivna ili negativna. Jedan dataset sadrži Twitter poruke koje iskazuju pozitivni sentiment, dok će drugi sadžati poruke sa izraženim negativnim emocijama. Funkciju *searchTwitter()* pozivamo dva puta za preuzimanje pozitivnih i negativnih poruka respektivno.

Postoje različiti emotikoni kojima se može izraziti pozitivna emocija ( :), :-), :D, :-D), kao i negativna. Međutim, ako funkciji prosledimo samo jedan od pozitivnih emotikona, npr. ':-)', dobićemo kao rezultat Twitter poruke sa bilo kojim od pozitivnih emotikonima. Slično smo uradili i sa negativnim emotikonima.
Ključnim rečima *exclude:retweets* uklonjeni su “retweetovi”, koji ukazuju na ponovno publikovanje nečije Twitter poruke. Ukoliko bi se takve twitter poruke uzele u razmatranje, tada bi jedna ista poruka bila ubrojana više puta, što želimo da izbegnemo. 
Pored broja Twitter poruka, funkcija prima parametar kojim specificiramo jezik na kom vršimo pretragu.

```R
tweetsPos<- searchTwitter(':)+storm+exclude:retweets', n=3000, lang='en')

tweetsNeg<- searchTwitter(':(+storm+exclude:retweets', n=3000, lang='en')
```

Nakon prikupljanja Twitter poruka formiran je dataframe-a sa strukturom koja je prikazana u sledećoj tabeli.

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/struktura.png)

Prikupljene Twitter poruke sa izraženim pozitivnim i negativnim emocijama sačuvane su u CSV dokumentima *positiveTweetsStorm.csv* i *negativeTweetsStorm.csv* respektivno. 

## Pretprocesiranje Twitter poruka

Mnoge twitter poruke u sebi sadrže linkove, spominjanja drugih osoba, cifre, znake interpunkcija i mnoge druge simbole koji nisu značajni za analizu sentimenta. Zbog toga je neophodno iz teksta svake Twitter poruke ukloniti sve reči i simbole koji nisu od značaja za samu sentiment analizu. 
Takođe, izbacivanje emotikona podstiče klasifikatore da uče iz drugih svojstava koji se nalaze u Twitter porukama. 

Nakon pretprocesiranja i uklanjanja svih duplikata poruka, formiran je dataframe koji sadrži sve prikupljene poruke. Pored samog teksta poruke, dataframe sadrži i promenljivu *class* koja deklariše da li poruka sadrži pozitivne ili negativne emocije. Za pozitivne poruke, class ima vrednost *pos*, dok za negativne poruke njena vrednost iznosi *neg*. Navedeni dataframe sačuvan je u dokumentu *cleanTweets.csv*.

Za nastavak transformacije podataka koristimo funkciju *tm_map()* iz paketa *tm*. Data funkcija omogućava različite transformacije teksta kao što su uklanjanje nepotrebnog praznog prostora i eliminacija učestanih reči engleskog jezika – stopwords (članovi, veznici itd). 
Za potrebe kreiranja korpusa i transformacije podataka formirana je dodatna funkcija *createAndCleanCorpus()*.

```R

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
```

### Kreiranje korpusa

Da bismo pripremili tekst za obradu, kreiraćemo korpus koji se sastoji od dokumenata među kojima svaki od njih predstavlja sadržaj određene Twitter poruke. 

```R
  #create a corpus from character vectors
  text_corpus = VCorpus(VectorSource(tweets))
```  

### Utvrđivanje najfrekventnijih reči u korpusu

U uvom pristupu svaku reč u dokumentu tretiramo kao atribut, dok je jedna Twitter poruka predstavljena kao vektor atributa. Radi jednostavnosti, zanamarujemo redosled reči u poruci, a fokusiramo se samo na broj pojavljivanja određene reči. Ovo postižemo kreiranjem term-document matrice. Redovi matrice odnose se na termine, dok kolone odgovaraju dokumentima u kolekciji. 
```R
> inspect(tdm)
<<TermDocumentMatrix (terms: 2948, documents: 1186)>>
Non-/sparse entries: 10557/3485771
Sparsity           : 100%
Maximal term length: 21
Weighting          : term frequency (tf)
Sample             :
      Docs
Terms  276 424 48 545 7 714 720 773 859 981
  and    0   2  1   0 0   0   1   2   1   0
  but    0   0  0   0 0   0   1   0   1   2
  for    0   0  0   1 2   0   1   0   1   0
  its    1   0  0   0 0   0   0   0   1   0
  that   0   0  0   1 1   0   0   0   0   0
  the    1   4  1   2 1   1   1   3   0   2
  this   1   0  0   0 0   0   0   0   0   0
  was    0   0  0   0 0   0   1   0   0   0
  with   0   0  0   0 0   0   0   0   0   0
  you    0   0  0   0 0   0   2   1   0   1
```

Kreirana je dodatna funkcija *findFreqWords()* koja omogućava pronalazak najfrekventnijih reči među svim Twitter porukama. 

```R
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
``` 

U nastavku su prikazane liste najfrekventnijih reči pre i posle ukljanjanja StopWords. 

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/fr.png)

Formirani dataset sadrži ukupno 1186 twitter poruke gde svaka od njih ima oznaku sentimenta pri čemu su obe klase ravnomerno prisutne.

## Kreiranje wordcloud-a
Wordcloud predstavlja zgodan alat ukoliko želimo da naglasimo neke reči iz teksta koje se najčešće pojavljuju. Daje veći značaj onim rečima čija je frekvencija pojavljivanja u izvornom tekstu veća. Za kreiranje wordcloud-a korišćen je paket *wordcloud* i istoimena funkcija kojoj prosleđujemo korpus. 

Parametri:
•	scale - kontroliše razliku između najvećeg i najmanjeg fona  
•	max.words – ograničava broj reči koje će se prikazati  
•	rot.per – procenat vertikalnog teksta.  

Wordcloud za pozitivne Twitter poruke:  
![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/WC_neg.png)  

Wordcloud za negativne Twitter poruke:  

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/WC_pos.png)  
  
## Kreiranje klasifikatora

Problem sentiment analize rešavamo rešavamo korišćenjem sledećih algoritama mašinskog učenja: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora.


### Kreiranje korpusa document-term matrice

S obzirom da su u dataset-u najpre navedene sve pozitivne poruke, a zatim sve negativne, neophodno je da randomizacijom izvršimo njihovo premeštanje na slučajan način. Nakon toga kreiramo korpus u kome će svaka Twitter poruka biti predstavljena kao jedan dokument. 
 
Za kreiranje korpusa i čišćenje podataka koristimo već kreiranu funkciju *createAndCleanCorpus()*.

Potrebno je da formiramo Document-Term matricu (DTM) koja odgovara dokumentima u kolekciji. Kolone matrice čine termini, a elementi odgovaraju frekvencijama svakog termina u određenoj Twitter poruci. Za kreiranje DTM koristimo ugrađenu funkciju *DocumentTermMatrix* iz biblioteke *tm*. 

### Selekcija atributa 

Kreirana Document-term matrica (DTM) sadrži 2860 atributa. S obzirom da nisu svi atributi korisni za klasifikaciju, izvršićemo redukciju atributa ignorišući one reči koje se pojavljuju u manje od 5 twitter poruka. 

Ograničićemo DTM da koristi samo željene reči pomoću opcije *dictionary*. 

```R
freq <- findFreqTerms(dtm_train, 5)
length((freq))

dtm2<- DocumentTermMatrix(clean_corpus_train, control=list(dictionary = freq))
dim(dtm2)
```

Nakon selekcije atributa dimenzije matrice iznose *1186 x 325*.

###  Kros validacija

Kros validacija predstavlja postupak kojim se originalni dataset deli na k jednakih delova (eng. folds). Na taj način trening se vrši nad k-1 delova dok jedan deo preostaje za validaciju. Dati process se ponavlja k puta tako što se svaki put različiti deo koristi za validaciju. Nakon toga izračunava se prosek svih iteracija. Cilj kros validacije je da se spreči problem overfitting-a, a da se predikcije učine generalnijim. Za potrebe kros validacije, korišćena je bibliotaka *caret* koja pruža funkcionalnost stratifikovane kros-validacije, što znači da se u svakom od dobijenih delova nalazi odgovarajuća proporcija podataka među klasama. 

U nastavnku se nalaze rezultati dobijeni kros validacijom sa podelom na 10 delova (folds=10) za tri različita modela: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora.

### Algoritam Naivni Bajes

Naivni Bajes, u suštini predstavlja primenu Bajesove teoreme, sa pretpostavkama nezavisnosti atributa. U ovom radu korišćena je varijacija Multinominalnog Naivnog Bajes-a koji je poznat kao binarizovani (Boolean feature) Naivni Bajes. Frekvencije termina zamenjujemo jednostavnim prisustvom tj. odsustvom određenog termina. 

Za treniranje modela korišćena je funkcija *train* iz biblioteke *caret*. Tačnost ovog modela je 77.2%.

```R
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

```


### Metoda maksimalne entropije 

Metoda maksimalne entropije predstavlja jedan od modela logističke regresije. Pripada klasi eksponencijalnih modela. Za razliku od Naivnog Bajesa, model maksimalne entropije ne pretpostavlja uslovnu nezavisnost među atributima. Metod maksimalne entropije zasniva se na principu maksimalne entropije i od svih modela koji odgovaraju trening podacima, bira onaj koji poseduje najveću entropiju. Ova metoda se osim za problem analize sentimenta često koristi za široku klasu problema klasifikacije teksta kao što su detekcija jezika, klasifikacija tema i druge. 

Kao i kod metode Naivnog Bajesa i za metodu maksimalne entropije izvršena je kros validacija (folds=10). U tu svrhu koristimo biblioteku *RTextTools*, koja u pozadini koristi biblioteku *e1071*. Dobijeni rezultati prikazani su u nastavku. Tačnost ovog modela iznosi 92%.

```R
# MAX ENTROPY
# create and train Max Entropy model
container <-create_container(dtm, as.numeric(clean_tweets_df$class), trainSize = 1:880, 
                             testSize = 881:1186, virgin = FALSE)  

# 10-folds cross validation
cross_validate(container, 10, "MAXENT")

Fold 1 Out of Sample Accuracy = 0.9280576
Fold 2 Out of Sample Accuracy = 0.9112903
Fold 3 Out of Sample Accuracy = 0.8760331
Fold 4 Out of Sample Accuracy = 0.9393939
Fold 5 Out of Sample Accuracy = 0.9
Fold 6 Out of Sample Accuracy = 0.8990826
Fold 7 Out of Sample Accuracy = 0.9416667
Fold 8 Out of Sample Accuracy = 0.9578947
Fold 9 Out of Sample Accuracy = 0.9173554
Fold 10 Out of Sample Accuracy = 0.9333333

$meanAccuracy
[1] 0.9204108

```

### Metoda potpornih vektora (Support Vector Machine)

Algoritam Support Vector Machine predstavlja još jednu od tehnika klasifikacije. Osnovna ideja jeste naći hiper-ravan koja razdvaja podatke tako da su svi podaci jedne klase sa iste strane date ravni. U ovom radu korišćena je metoda potpornih vektora sa linearnim jezgrom. Zadatak treniranja podataka podrazumeva pronalazak optimalne linearne ravni koja razdvaja podatke za trening. Optimalna hiper-ravan je ona koja poseduje maksimalnu marginu odnosno rastojanje među podacima za trening. Kao rezultat dobijamo hiper-ravan koja je potpuno određena podskupom podataka za trening koji se nazivaju podržavajući (potporni) vektori [3].

Na sličan način kao i kod metoda Naivni Bajes, kreiran je klasifikator zasnovan na metodi potpornih vektora korišćenjem R biblioteke *caret*. Nakon izvršene kros validacije za model zasnovan na potpornim vektorima dobijeni su sledeći rezultati:

```R
> modelSVM
Support Vector Machines with Linear Kernel 

No pre-processing
Resampling: Cross-Validated (10 fold) 
Summary of sample sizes: 1067, 1068, 1067, 1068, 1067, 1067, ... 
Resampling results:

  Accuracy   Kappa    
  0.7597422  0.2480407

Tuning parameter 'C' was held constant at a value of 1
```


## Tumačenje rezultata

Tačnost predviđanja modela klasifikacije iskazuje se procentom ispravno predviđenih instanci u odnosu na njihov ukupan broj.  

Upoređena je tačnost data 3 tri algoritma primenom kros-validacije. 
Tačnost algoritma Naivni Bajes iznosi  77.2%. Dobijene loše rezultate možemo jedino prepisati nereprezentativnim prikupljenim podacima.  

Primenom kros/validacije za metodu Maksimalne Entropije, tačnost modela iznosi 92% dok je za metoda Potpornih vektora dobijena tačnost 76%. 

Nakon terstiranja klasifikatora Naivni Bajes, Maksimalna entropija i metoda potpornih vektora zaključeno je da najbolje performanse, kada je u pitanju kros validacija, pruža metoda Maksimalne entropije. U nastavku upoređene su dobijene tačnosti datih algorima tokom kros validacije:

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/comparation.png)

 

## Literatura
[1] Go A, Bhyani R, Huang L, „Twitter Sentiment Classification using Distant Supervision“, pages 1-6 

[2] Bo Pang and Lillian Lee Sentiment analysis and opinion mining, Foundations and Tredns in Information Retrieval, Volume 2 Issue 1-2, January 2008  

[3] B. Pang, L. Lee, and S. Vaithyanathan, Thumbs up? Sentiment classification using machine learning techniques, pp. 79–86, 2002. 
