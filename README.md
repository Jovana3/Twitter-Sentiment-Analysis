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

Često može biti neodređeno da li određena twitter poruka sadrži emociju. Takve twitter poruke nazivamo neutralnim. Međutim, u ovom radu neutralne poruke nisu uzete u razmatranje prilikom analize sentimenta.  

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

Radi kreiranja boljih klasifikatora, cilj je prikupiti što veći uzorak. Zbog toga ćemo najpre izvrštiti analizu trendova u celom svetu, prema objašnjenom postupku, kako bismo prikupili što veći broj Twitter poruka. Nakon sagledavanja aktuelnih tema, odlučeno je da ključna reč upita koji će se korisiti bude hashtag #RussianGP (Russian Grand Prix).

#### Formiranje i izvršenje upita

Da bismo mogli da prikupimo podatke putem Twitter API servisa, neophodno je da ispoštujemo određen format upita koji servis zahteva. Za pretragu Twitter-a korišćena je raspoloživa funkcija *searchTwitter()*. Ukoliko želimo da izvršimo jednostavnu pretragu po nekoj ključnoj reči, dovoljno je da funkciji prosledimo datu ključnu reč. Za komplikovanije pretrage moguće je koristiti različite operatore kojima se može promeniti ponašenja upita. U sledećoj tabeli navedeni su neki od operatora koji su zajedno sa objašnjenim ponašanjem dostupni u Twitter Search API dokumentaciji. 

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/operators.png)

Funkcija *searchTwitter()* izvršava pretragu Twitter-a na osnovu prosleđenog stringa. Poseduje sledeću sintaksu:

```R
searchTwitter (searchString, n=25, lang=NULL, since=NULL, until=NULL, locale=NULL,  
              geocode=NULL, sinceID=NULL, maxID=NULL, resultType=NULL, retryOnRateLimit=120)
```

Kako bismo izvršili testiranje klasifikatora, neophodno je da pripremimo 2 oveležena dataset-a sa Twitter porukama gde je svaka od njih označena kao pozitivna ili negativna. Jedan dataset sadrži Twitter poruke koje iskazuju pozitivni sentiment, dok će drugi sadžati poruke sa izraženim negativnim emocijama. Funkciju *searchTwitter()* pozivamo dva puta za preuzimanje pozitivnih i negativnih poruka respektivno.

Postoje različiti emotikoni kojima se može izraziti pozitivna emocija ( :), :-), :D, :-D), kao i negativna. Međutim, ako funkciji prosledimo samo jedan od pozitivnih emotikona, npr. ':-)', dobićemo kao rezultat Twitter poruke sa bilo kojim od pozitivnih emotikonima. Slično smo uradili i sa negativnim emotikonima. Pored broja Twitter poruka, funkcija prima parametar kojim specificiramo jezik na kom vršimo pretragu.

```R
tweets <- searchTwitter('#RussianGP :)', n=10000, lang='en')

tweets2 <- searchTwitter('#RussianGP :(', n=10000, lang='en')
```

Nakon prikupljanja Twitter poruka formiran je dataframe-a sa strukturom koja je  prikazana u sledećoj tabeli.

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/struktura.png)

Prikupljene Twitter poruke sa izraženim pozitivnim i negativnim emocijama sačuvane su u CSV dokumentima *positiveTweets.csv* i *negativeTweets.scv* respektivno. 

## Predprocesiranje Twitter poruka

Mnoge twitter poruke u sebi sadrže linkove, spominjanja drugih osoba, cifre, znake interpunkcija i mnoge druge simbole koji nisu značajni za analizu sentimenta. Zbog toga je neophodno iz teksta svake Twitter poruke ukloniti sve reči i simbole koji nisu od značaja za samu sentiment analizu. 

Takođe, uklonjeni su “retweetovi”, koji ukazuju na ponovno publikovanja nečije Twitter poruke. Ukoliko bi se takve twitter poruke uzele u razmatranje, tada bi jedna ista poruka bila ubrojana više puta, što želimo da izbegnemo. Takve poruke prepoznajemo pomoću oznake RT na početku sadržaja poruke.

Nakon predprocesiranja i uklanjanja svih duplikata poruka, formiran je dataframe koji sadrži sve prikupljene poruke. Pored samog teksta poruke, dataframe sadrži i promenljivu *class* koja deklariše da li poruka sadrži pozitivne ili negativne emocije. Za pozitivne poruke, class ima vrednost *pos*, dok za negativne poruke njena vrednost iznosi *neg*. Navedeni dataframe sačuvan je u dokumentu *cleanTweets.csv*.

Za nastavak transformacije podataka koristimo funkciju *tm_map()* iz paketa *tm*. Data funkcija omogućava različite transformacije teksta kao što su uklanjanje nepotrebnog praznog prostora i eliminacija učestanih reči engleskog jezika – stopwords (članovi, veznici itd). 
Za potrebe kreiranja korpusa i transformacije podataka formirana je dodatna funkcija *createAndCleanCorpus()*.

```R
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
<<TermDocumentMatrix (terms: 5468, documents: 9182)>>
Non-/sparse entries: 79355/50127821
Sparsity           : 100%
Maximal term length: 33
Weighting          : term frequency (tf)
Sample             :
        Docs
Terms    1525 3140 4234 4253 4323 438 7245 8819 8840 8910
  and       0    1    1    0    0   1    1    1    0    0
  bottas    0    1    0    0    0   0    1    0    0    0
  for       0    0    0    0    2   1    0    0    0    2
  from      0    0    0    0    0   0    0    0    0    0
  kimi      0    0    0    0    0   0    0    0    0    0
  latest    0    0    0    0    0   0    0    0    0    0
  race      0    0    1    1    0   1    0    1    1    0
  the       1    0    3    0    0   0    0    3    0    0
  win       0    0    0    0    0   0    0    0    0    0
  with      0    1    0    0    0   0    1    0    0    0
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
Sagledavanjem delimično pročišćenih podataka, ustanovljeno je da postoje reči čija je frekvencija pojavljivanja velika, ali nemaju veći značaj na samu analizu sentimenta. Stoga je odlučeno da se sledeće reči eliminišu iz Twitter poruka: *russian, russia, grand, prix, f, russiangrandprix, russiangp.*

U nastavku su prikazane liste najfrekventnijih reči posle ukljanjanja StopWords i nerelevantnih reči. 

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/freq.png)

Formirani dataset sadrži ukupno 9182 twitter poruke gde svaka od njih ima oznaku sentimenta pri čemu su obe klase ravnomerno prisutne.

## Kreiranje wordcloud-a
Wordcloud predstavlja zgodan alat ukoliko želimo da naglasimo neke reči iz teksta koje se najčešće pojavljuju. Daje veći značaj onim rečima čija je frekvencija pojavljivanja u izvornom tekstu veća. Za kreiranje wordcloud-a korišćen je paket *wordcloud* i istoimena funkcija kojoj prosleđujemo korpus. 

Parametri:
•	scale - kontroliše razliku između najvećeg i najmanjeg fona  
•	max.words – ograničava broj reči koje će se prikazati  
•	rot.per – procenat vertikalnog teksta.  

Wordcloud za pozitivne Twitter poruke:  
![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/WCNegativeTweets.png)  

Wordcloud za negativne Twitter poruke:  

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/WCPositiveTweets.png)  
  
## Kreiranje klasifikatora

Problem sentiment analize rešavamo rešavamo korišćenjem sledećih algoritama mašinskog učenja: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora.

### Naivni Bajes

#### Kreiranje korpusa document-term matrice

S obzirom da su u dataset-u najpre navedene sve pozitivne poruke, a zatim sve negativne, neophodno je da randomizacijom izvršimo njihovo premeštanje na slučajan način. Nakon toga kreiramo korpus u kome će svaka Twitter poruka biti predstavljena kao jedan dokument. 
 
Za kreiranje korpusa i čišćenje podataka koristimo već kreiranu funkciju *createAndCleanCorpus()*.

Potrebno je da formiramo Document-Term matricu (DTM) koja odgovara dokumentima u kolekciji. Kolone matrice čine termini, a elementi odgovaraju frekvencijama svakog termina u određenoj Twitter poruci. Za kreiranje DTM koristimo ugrađenu funkciju *DocumentTermMatrix* iz biblioteke *tm*. 

#### Particionisanje podataka

Kostićemo funkciju *createDataPartition()* kako bismo podelili dati dataset na deo za trening i deo za testiranje prema razmeri 80:20. Treniraćemo Naïve Bayes klasifikator na trening dataset-u, a zatim njegove performanse proveriti na test dataset-u. Proporcija pozitivnih i negativnih poruka iznosti 50:50. Proverićemo da je tokom postupka particionisanja sačuvana ista proporcija u delu za trening i obuku. Kako bismo to proverili kreirana je dodatna funkcija *frqtab()*.

```R
frqtab <- function(x, caption) {
  round(100*prop.table(table(x)), 1)
}


|  &nbsp;   |  Original  |  Training set  |  Test set  |
|:---------:|:----------:|:--------------:|:----------:|
|  **neg**  |     50     |       50       |    49.9    |
|  **pos**  |     50     |       50       |    50.1    |

Table: Comparison of sentiment class frequencies among datasets
```

### Selekcija atributa 

Kreirana Document-term matrica (DTM) sadrži 5372 atributa. S obzirom da nisu svi atributi korisni za klasifikaciju, izvršićemo redukciju atributa ignorišući one reči koje se pojavljuju u manje od 50 twitter poruka. 

Ograničićemo DTM da koristi samo željene reči pomoću opcije *dictionary*. 

```R
freq <- findFreqTerms(dtm_train, 50)
length((freq))

dtm_train_nb <- DocumentTermMatrix(clean_corpus_train, control=list(dictionary = freq))
dim(dtm_train_nb)
```

Nakon selekcije atributa dimenzije matrice za trening iznose *7346 x167* dok su dimenzije matrice za testiranje *1836 x167*.

### Algoritam Naivni Bajes

Naivni Bajes, u suštini predstavlja primenu Bajesove teoreme, sa pretpostavkama nezavisnosti atributa. U ovom radu korišćena je varijacija Multinominalnog Naivnog Bajes-a koji je poznat kao binarizovani (Boolean feature) Naivni Bajes. Frekvencije termina zamenjujemo jednostavnim prisustvom tj. odsustvom određenog termina. 

Za treniranje modela korišćena je funkcija *naiveBayes* iz biblioteke *e1071*. S obzirom da Naivni Bajes izračunava proizvode verovatnoća, moramo obezbediti način da izbegnemo dodeljivanje nule onim rečima koje nisu prisutne u poruci. Zbog toda koristimo parameter laplace, koji ima vrednost 1. 

```R
# use the NB classifier we built to make predictions on the test set.
system.time(prediction <- predict(classifierNB, newdata=testNB))
```

Nakon testiranja dobijenog klasifikatora na test dataset-u kreiramo matricu konfuzije. Tačnost ovog modela je 44.4%.

```R
Confusion Matrix and Statistics

          Reference
Prediction neg pos
       neg 501 604
       pos 416 315
                                          
               Accuracy : 0.4444          
                 95% CI : (0.4215, 0.4675)
    No Information Rate : 0.5005          
    P-Value [Acc > NIR] : 1               
                                          
                  Kappa : -0.1109         
 Mcnemar's Test P-Value : 4.764e-09       
                                          
            Sensitivity : 0.5463          
            Specificity : 0.3428          
         Pos Pred Value : 0.4534          
         Neg Pred Value : 0.4309          
             Prevalence : 0.4995          
         Detection Rate : 0.2729          
   Detection Prevalence : 0.6019          
      Balanced Accuracy : 0.4446          
                                          
       'Positive' Class : neg  
```
####  Kros validacija

Kros validacija predstavlja postupak kojim se originalni dataset deli na k jednakih delova (eng. folds). Na taj način trening se vrši nad k-1 delova dok jedan deo preostaje za validaciju. Dati process se ponavlja k puta tako što se svaki put različiti deo koristi za validaciju. Nakon toga izračunava se prosek svih iteracija. Cilj kros validacije je da se spreči problem overfitting-a, a da se predikcije učine generalnijim. Za potrebe kros validacije, korišćena je bibliotaka *caret* koja pruža funkcionalnost stratifikovane kros-validacije, što znači da se u svakom od dobijenih delova nalazi odgovarajuća proporcija podataka među klasama. 

U nastavnku se nalaze rezultati dobijenog modela kros validacijom sa podelom na 10 delova (folds=10). Tačnost ovog modela Naivnog Bajesa iznosi 45.9%.

```R
Naive Bayes 

7346 samples
 167 predictor
   2 classes: 'neg', 'pos' 

No pre-processing
Resampling: Cross-Validated (10 fold) 
Summary of sample sizes: 6611, 6611, 6611, 6612, 6611, 6611, ... 
Resampling results across tuning parameters:

  usekernel  Accuracy  Kappa      
  FALSE      0.45902   -0.08180484
   TRUE      0.45902   -0.08180484

Tuning parameter 'fL' was held constant at a value of 0
Tuning parameter
 'adjust' was held constant at a value of 1
Accuracy was used to select the optimal model using  the largest value.
The final values used for the model were fL = 0, usekernel = FALSE and adjust = 1.
```

### Metoda maksimalne entropije 

Metoda maksimalne entropije predstavlja jedan od modela logističke regresije. Pripada klasi eksponencijalnih modela. Za razliku od Naivnog Bajesa, model maksimalne entropije ne pretpostavlja uslovnu nezavisnost među atributima. Metod maksimalne entropije zasniva se na principu maksimalne entropije i od svih modela koji odgovaraju trening podacima, bira onaj koji poseduje najveću entropiju. Ova metoda se osim za problem analize sentimenta često koristi za široku klasu problema klasifikacije teksta kao što su detekcija jezika, klasifikacija tema i druge. 

Kako bismo kreirali model maksimalne entropije, koristimo biblioteku *RTextTools*, koja u pozadini koristi biblioteku *e1071*. Dobijene performanse algoritma prikazane su u nastavku. Preciznost ovog modela iznosi 44.4%.

```R
ALGORITHM PERFORMANCE

MAXENTROPY_PRECISION    MAXENTROPY_RECALL    MAXENTROPY_FSCORE 
                0.44                 0.44                 0.44 
```

#### Kros validacija

Kao i kod metode Naivnog Bajesa i za metodu maksimalne entropije izvršena je kros validacija (folds=10). Dobijeni su sledeći rezultati:

```R
Fold 1 Out of Sample Accuracy = 0.4922395
Fold 2 Out of Sample Accuracy = 0.5083857
Fold 3 Out of Sample Accuracy = 0.4793028
Fold 4 Out of Sample Accuracy = 0.5080808
Fold 5 Out of Sample Accuracy = 0.504662
Fold 6 Out of Sample Accuracy = 0.5163105
Fold 7 Out of Sample Accuracy = 0.5286195
Fold 8 Out of Sample Accuracy = 0.5113872
Fold 9 Out of Sample Accuracy = 0.5276008
Fold 10 Out of Sample Accuracy = 0.5114679

$meanAccuracy
[1] 0.5088057

```

S obzirom da tačnost dobijenog modela maksimalne entropije iznosi 50.8%, zaključujemo da je metod maksimalne entropije imao neznatno bolje performance od algoritma Naivni Bajes. 

### Metoda potpornih vektora (Support Vector Machine)

Algoritam Support Vector Machine predstavlja još jednu od tehnika klasifikacije. Osnovna ideja jeste naći hiper-ravan koja razdvaja podatke tako da su svi podaci jedne klase sa iste strane date ravni. U ovom radu korišćena je metoda potpornih vektora sa linearnim jezgrom. Zadatak treniranja podataka podrazumeva pronalazak optimalne linearne ravni koja razdvaja podatke za trening. Optimalna hiper-ravan je ona koja poseduje maksimalnu marginu odnosno rastojanje među podacima za trening. Kao rezultat dobijamo hiper-ravan koja je potpuno određena podskupom podataka za trening koji se nazivaju podržavajući (potporni) vektori. 

Na sličan način kao i kod metoda maksimalne verodostojnosti, kreiran je klasifikator zasnovan na metodi potpornih vektora korišćenjem R biblioteke *RTextTools*. Preciznost ovog modela iznosi 58%.

```R
ALGORITHM PERFORMANCE

SVM_PRECISION    SVM_RECALL    SVM_FSCORE 
        0.580         0.575         0.575 
```

#### Kros validacija

Nakon izvršene kros validacije za model zasnovan na potpornim vektorima dobijeni su sledeći rezultati:

```R
Fold 1 Out of Sample Accuracy = 0.3859275
Fold 2 Out of Sample Accuracy = 0.3901345
Fold 3 Out of Sample Accuracy = 0.3665944
Fold 4 Out of Sample Accuracy = 0.377014
Fold 5 Out of Sample Accuracy = 0.3624309
Fold 6 Out of Sample Accuracy = 0.3732162
Fold 7 Out of Sample Accuracy = 0.3737143
Fold 8 Out of Sample Accuracy = 0.3729508
Fold 9 Out of Sample Accuracy = 0.4015234
Fold 10 Out of Sample Accuracy = 0.3800657

$meanAccuracy
[1] 0.3783572
```

## Tumačenje rezultata

Tačnost predviđanja modela klasifikacije iskazuje se procentom ispravno predviđenih instanci u odnosu na njihov ukupan broj.  

Tačnost algoritma Naivni Bajes iznosi skromnih 44.4% u slučaju kada radimo podelu dataseta na trening i test dataset u odnosu 80:20. U slučaju primene kros/validacije, tačnost iznosi 45.9%. Dobijene loše rezultate možemo jedino prepisati nereprezentativnim prikupljenim podacima. Stoga je planirani korak dalje analize ponoviti opisani postupak nad novim podacima. 

Nakon terstiranja klasifikatora Naivni Bajes, Maksimalna entropija i metoda potpornih vektora zaključeno je da najbolje performance pruža metoda maksimalne entropije. U nastavku upoređene su dobijene tačnosti datih algorima tokom kros validacije:

![alt text](https://github.com/Jovana3/Twitter-Sentiment-Analysis/blob/master/img/comparation.png)
 

## Literatura
[1] Go A, Bhyani R, Huang L, „Twitter Sentiment Classification using Distant Supervision“, pages 1-6 

[2] Vieweg, S., Palen, L., Liu, S. B., Hughes, A. L., and Sutton, J., “Collective intelligence in disaster: An examination of the phenomenon in the aftermath of the 2007 Virginia Tech shootings.”, In Proceedings of the Information Systems for Crisis Response and Management Conference (ISCRAM). 2008.

[3] Bo Pang and Lillian Lee Sentiment analysis and opinion mining, Foundations and Tredns in Information Retrieval, Volume 2 Issue 1-2, January 2008. 
[4] B. Pang, L. Lee, and S. Vaithyanathan, Thumbs up? Sentiment classification using machine learning techniques, in Proceedings of the Conference on Empirical Methods in Natural Language Processing (EMNLP), pp. 79–86, 2002. 
