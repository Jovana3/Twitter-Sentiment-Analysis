# Twitter-Sentiment-Analysis

##Sadržaj 

Količina informacija koja protiče društvenim mrežama svakodnevno se povećava, i predstavlja bogat izvor podataka, koji ako se pravilno semantički obradi, može biti veoma koristan u najrazličitijim oblastima. Cilj ovo projekta je analiza sentimenta Twitter poruka primenom algoritama mašinskog učenja. 

U radu su korišćeni sledeći algoritmi: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora. 

Osnovna ideja je prikupljanje tekstualnih podataka u cilju konstrukcije i evaluacije različitih klasifikatora za analizu sentimenta Twitter poruka. Dobijeni klasifikatori su testirani i međusobno upoređeni u cilju pronalaska onog koji pruža najbolje performance klasifikacije Twitter poruka. 

##Uvod

Korišćenje Interneta kao komunikacionog kanala omogućilo je da društvene mreže i servisi za mikroblogovanje postanu značajan potencijalni izvor znanja koje se kasnijom semantičkom obradom i analizom mogu koristiti u procesima donošenja odluka.

Velika količina podataka koja se svakog dana generiše putem interneta pripada nestruktuiranim podacima tekstualnog tipa. Mašinsko učenje omogućava da sistem prepozna date reči i pripoji im neko smisleno značenje. 

##Motiv za izbor Twitter aplikacije

Svakodnevni porast i prisutnost mobilnih uređaja u svakodnevnom životu, u velikoj meri su olakšali pristup društvenim mrežama, i pojednostavili način deljenja informacija jednim klikom. Mikroblogovanje kao jedan  od oblika društvenih mreža se već uveliko integrisao u svakodnevni život i postao deo svakodnevne komunikacije i razmene informacija. Smatra se da su podaci proizvedeni mikroblogovanjem nedvosmisleni, brzi i pristupačni. Twitter, kao najpoznatiji servis za mikrobloging, izuzetno je pogodan je za procenu stava ogromnog broja korisnika. 

Pored toga, podaci sa Twitter-a su posebno interesantni jer se poruke pojavljuju „brzinom misli“ odnosno dostupni su za preuzimanje momentalno, jer se sve odigrava u „skoro realnom vremenu“ (eng. near real-time).  

##Definicija anlalize sentimenta

Analiza sentimenta Twitter poruke obuhvata process određivanja emotivnog tona na osnovu niza reči a koristi se kako bi se steklo razumevanje stava, mišljenja i emocija koji su izraženi u okviru online poruke. U ovom radu korišćena je binarna klasifikacija twitter poruke u dve klase: pozitivnu i negativnu.
Često može biti neogređeno da li određena twitter poruka sadrži emociju. Takve twitter poruke nazivamo neutralnim. Međutim, u ovom radu neutralne poruke nisu uzete u razmatranje prilikom analize sentimenta.  

Za treniranje određenog klasifikatora, najčešće su potrebni ručno obeleženi podaci. Međutim sa velikim brojem tema koje su diskutovane na Twitter-u bilo bi teško prikupiti veliki broj twitter poruka koji je potreban za trening klasifikatora. Stoga, u ovom radu korišćena je automatska ekstrakcija osećenja iz twitter poruka na osnovu emotikona. Na primer, emotikon :) ukazuje da se radi o poruci sa pozitivnom emocijom, dok emotikon :( ukazuje da je izražena negativna emocija.  

##Prikupljanje podataka putem Twitter API servisa

Twitter API (Application Programming Interface) je sistem za pristup Twitter serverima i bazi podataka radi ekstrakcije rezultata upita. 
Twitter servis svima stavlja na raspolaganje sve informacije od onog momenta kada su objavljene. Putem Twitter API servisa omogućen je pristup popularnim ili nedavnim twitter porukama koje su objavljene u poslednjih 7 dana. Takođe moguće je pristupiti i podacima o geolokaciji svake Twitter poruke.  Na taj način omogućeno proučavanje kako tekstualnih tako i lokacijskih karakteristika online sadržaja.

Upiti se šalju u obliku url adrese, i u sebi sadrže ključne reči pretrage i druge parametre. Naravno postoje ograničenja sa serverske strane o broju upita, odnosno zahteva koje se mogu uputiti u minuti. 
U ovom radu korišćen je Twitter Search API, koji za razliku od Stream API-ja poseduje određena ograničenja prilikom slanja upita i pretraživanja podataka. Upiti koji pretražuju tvitove mogu da vrate maksimalno do 100 tvitova po jednom upitu. Takođe kao što je već naglašeno, nije moguće pretraživati stare tvitove, već samo one objavljene u proteklih sedam dana.

Razvijene su mnogobrojne biblioteke za različite programske jezike koje koriste Twitter API za pretragu podataka, odnosno text mining. U ovom radu korišćene su biblioteke za R programski jezik među kojima su najbitnije: twitteR, tm(text mining), RTextTools, e1071 i caret.
Za preuzimanje podataka putem Twitter API servisa možemo izdvojiti sledeće glavne korake:

•	Kreiranje  i registrovanje aplikacije na razvojnoj stranici Twitter-a
•	Preuzimanje neophodnih biblioteka za R programski jezik
•	Pokretanje upita i čuvanje podataka

###Kreiranje  i registrovanje aplikacije na razvojnoj stranici Twitter-a

S obzirom da Twitter zahteva autorizaciju prilikom korišćenja svojih servisa, bilo je neophodno kreirati i registrovati aplikaciju na razvojnoj stranici Twitter-a. Postoji mogućnost i autorizacije bez aplikacije, ali su tada ograničenja veća, pa je zbog toga odlučeno  da se koristi OAuth 1 sistem autorizacije koji poseduje četiri parametra za pristup: 
•	API key,
•	API secret,
•	Access Token 
•	Access Token Secret.
Ovi parametri su trajni kada se jednom kreiraju, pa ih je moguće koristiti dok god postoji registrovana aplikacija. 
Nakon kreiranja aplikacije, preuzeti parametri su sačuvani dokumentu pod nazivom twitter_auth.csv.


Slika 1 Sadržaj fajla twitter_auth.csv

Autorizacija je uspostavljenja korišćenjem raspoložive funkcije setup_twitter_oauth() kojoj su prosleđeni dati parametri. 

###Izbor ključne reči za pretragu
Biblioteka twitteR nudi mogućnost sagledavanja trenda, odnostno aktuelne teme za određeno geografsko područje. Funkcjia availableTrendLocations() vraća informacije o trenutno dostupnim lokacijama uz njihov woeid (where on Earth ID). 
Stoga, možemo koristiti funkciju getTrends() koja prikazuje trenutne trendove za specificirani woeid tražene lokacije. Ukoliko želimo pretragu za ceo svet, woeid iznosi 1. 

Radi kreiranja boljih klasifikatora cilj je prikupiti što veći uzorak. Zbog toga ćemo najpre izvrštiti analizu trendova u celom svetu, prema objašnjenom postupku, kako bismo prikupili što veći broj twitter poruka. Nakon sagledavanja aktuelnih tema, odlučeno je da ključna reč upita koji će se korisiti bude hashtag #RussianGP (Russian Grand Prix).

 
###Formiranje i pokretanje upita

Da bismo mogli da prikupimo podatke putem Twitter API servisa neophodno je da ispoštujemo određen format Search upita koji servis zahteva. Za pretragu Twitter-a korišćena je raspoloživa funkcija searchTwitter().
Ukoliko želimo da izvršimo jednostavnu pretragu po nekoj ključnoj reči dovoljno je da funkciji prosledimo datu ključnu reč. Za komplikovanije pretrage moguće je koristiti različite operatore kojima se može promeniti ponašenja upita. U tabeli1 navedeni su neki od operatora koji su zajedno sa objašnjenim ponašanjem dostupni u Twitter Search API dokumentaciji. 





Za preuzimanje twitter poruka koristili smo funkciju searchTwitter() koja nam je dostupna putem biblioteke twitteR. Data funkcija izvršava pretragu Twitter-a na osnovu prosleđenog stringa. Poseduje sledeću sintaksu:

searchTwitter (searchString, n=25, lang=NULL, since=NULL, until=NULL, locale=NULL, geocode=NULL, sinceID=NULL, maxID=NULL, resultType=NULL, retryOnRateLimit=120)

Kako bismo izvršili testiranje klasifikatora neophodno je da pripremo 2 dataset-a sa twitter porukama, gde je svaka od njih označena kao pozitivna ili negativna. Jedan dataset sadrži twitter poruke koje iskazuju pozitivni sentiment, dok će drugi sadžati poruke sa izraženim negativnim emocijama. Funkciju searchTwitter() pozivamo dva puta za preuzimanje pozitivnih i negativnih poruka respektivno. 
Postoje različiti emotikoni kojima se može izraziti pozitivna emocija ( :), :-), :D, :-D), kao i negativna. Međutim, ako funkciji prosledimo samo jedan od pozitivnih emotikona :-), dobićemo kao rezultat twitter poruke sa svim pozitivnim emotikonima. Pored broja twitter poruka, funkcija prima parametar kojim specificiramo jezik na kom vršimo pretragu.




Date linije koda pokretane su nekoliko puta u cilju formiranja uzorka zadovoljavajućih dimenzija. Nakon prikupljanja twitter poruka formiran je dataframe-a sa strukturom koja je  prikazana u tabeli 2.

NAZIV PROMENLJIVE
TIP PROMENLJIVE
OPIS PROMENLJIVE
created
POSIXct
Datum i vreme nastanka twitter poruke
id
Character
ID poruke
text
Character
Sadržaj poruke
screenName
Character
Korisničko ime
retweetCount
Numeric
Broj ponovljenih poruka

Prikupljene  twitter poruke sa izraženim pozitivnim I negativnim emocijama sačuvane su u CSV dokumentima positiveTweets.csv i negativeTweets.scv respektivno. 

##Obrada twitter poruka

Za sprovođenje sentiment analize potrebno je najpre izvršiti obradu prikupljenih twitter poruka. 

Mnoge twitter poruke u sebi sadrže linkove, oznake drugih osoba, cifre, znake interpunkcija, i mnoge druge simbole. Zbog toga je neophodno iz teksta svake twitter poruke ukloniti sve reči i simbole koji nisu od značaja za samu sentiment analizu. 

Takođe, uklonjeni su “retweetovi”, koji ukazuju na kopiranje nečije twitter poruke i postavljanja preko drugog naloga. Ukoliko bi se takve twitter poruke uzele u razmatranje, tada bi jedna ista poruka bila ubrojana više puta, što želimo da izbegnemo. NJih prepoznajemo pomoću oznake RT na početku poruke. Nakon odstranjivanja date oznake uklanjamo sve ponovljene twitter poruke. Na taj način sigurni smo da je svaka poruka među prikupljenim podacima unikatna. 


Congratulations to newest Flying Finn! Below every one is a shark 😊 Making a great race out of a boring track/tyre… https://t.co/BkR9deJFyQ
RT @niki01103: The bigest suprise of the day: First row for #ScuderiaFerrari 😮#RussianGP #Formula1 #mifolyikittgyöngyösön #sochigp https://…
RT @redbullracing: Congrats to @ValtteriBottas on his first #F1 win #RussianGP #ГранПриРоссии https://t.co/W4R4ZgFw05
U tabeli 3 navedeni su primeri twitter poruka pre obrade


Sadržaj navedenih poruka nakon primarne obrade prikazan je u tabeli 4.
 
congratulations to newest flying finn below every one is a shark  making a great race out of a boring tracktyre
the bigest suprise of the day first row for scuderiaferrari  formula mifolyikittgyngysn sochigp
congrats to  on his first f win  


Nakon prvobitne obrade i uklanjanja svih duplikata poruka, formiran je dataframe koji integriše sve prikupljene poruke. Pored samog teksta poruke, dataframe sadrži i promenljivu class koja deklariše da li poruka sadrži pozitivne ili negativne emocije. Za pozitivne poruke, class ima vrednost pos, dok za negativne poruke njena vrednost  iznosi neg. Navedeni dataframe sačuvan je u dokumentu cleanTweets.csv.

##Tokenizacija i transformacija podataka

Za nastavak transformacije podataka koristimo funkciju tm_map() iz paketa tm. Data funkcija omogućava različite transformacije tekta kao što su uklanjanje nepotrebnog praznog prostora i eliminacija učestanih reči engleskog jezika – stopwords (članovi, veznici itd). 
Za potrebe kreiranja korpusa i transformacije podataka formirana je dodatna funkcija createAndCleanCorpus().

###Kreiranje korpusa

Da bismo pripremili tekst za obradu, kreiraćemo korpus koji se sastoji dokumenata među kojima svaki od njih predstavlja sadržaj određene twitter poruke. 


###Utvrđivanje najfrekventnijih reči u korpusu

U uvom pristupu svaku reč u dokumentu tretiramo kao atribut, dok je jedna twitter poruka predstavljena kao vektor atributa. Radi jednostavnosti, zanamarujemo redosled reči u poruci a fokusiramo se samo na broj pojavljivanja određene reči. 

Ovo postižemo kreiranjem term-document matrice. Redovi matrice odnose se na termine, dok kolone odgovaraju dokumentima u kolekciji. 


Slika 2 Term - document matrica

Kreirana je dodatna funkcija findFreqWords() koja omogućava pronalazak najfrekventnijih reči među svim twitter porukama. 
Sagledavanjem delimično pročišćenih podataka, ustanovljeno je da postoje reči čija je frekvencija pojavljivanja velika ali nemaju veći značaj na samu analizu sentimenta. 
Stoga odlučeno je da sledeće reči eliminišu iz twitter poruka: russian, russia, grand, prix, f, russiangrandprix, russiangp.
U tabeli 5 prikazane su promenjene liste najfrekventnijih reči posle ukljanjanja StopWords i datih nerelevantnih reči. 

Lista najfrekventnijih reči na početku
Lista najfrekventnijih reči posle uklanjanja stopwords
Lista najfrekventnijih reči posle uklanjanja stopwords i nerelevantnih reči


Tabela 5:  Lista najfrekventnijih reči sa brojem pojavljivanja

##Kreiranje wordcloud-a
Wordcloud predstavlja zgodan alat ukoliko želimo da naglasimo neke reči iz teksta koje se najčešće pojavljuju. Daje veći značaj onim rečima čija je frekvencija pojavljivanja u izvornom tekstu veća.
Za kreiranje wordcloud-a korišćen je paket wordcloud i istoimena funkcija kojoj prosleđujemo korpus vector. 

Parametri:

•	scale - kontroliše razliku između najvećeg i najmanjeg fona
•	max.words – ograničava broj reči koje će se prikazati
•	rot.per – procenat vertikalnog teksta


Slika 3 Wordcloud za pozitivne  twitter poruke

Slika 4 Wordcloud za negativne twitter poruke

##Kreiranje klasifikatora

Problem sentiment analize rešavamo rešavamo korišćenjem sledećih algoritama mašinskog učenja: Naivni Bajes, Maksimalna entropija i Metoda potpornih vektora. 
Naivni Bajes
Kako bismo kalsifikovali twitter poruke prema njihovom sentiment na pozitivne i negativne, korišćen je Naivni Bajes algoritam klasifikacije.

Formirani dataset sadrži ukupno 9182 twitter poruke gde svaka od njih ima oznaku sentimenta pri čemu su obe klase ravnomerno prisutne. 

###Kreiranje korpusa document-term matrice

S obzirom da su u dataset-u najpre navedene sve pozitivne poruke, a zatim sve negativne, neophodno je da randomizacijom izvršimo njihovo premeštanje na slučajan način. Nakon toga kreiramo korpus u kome će svaka twitter poruka biti predstavljena kao jedan dokument. 
 
Za kreiranje korpusa i čišćenje podataka koristimo već kreiranu funkciju createAndCleanCorpus().

Potrebno je da formiramo Document-Term matricu koja odgovara dokumentima u kolekciji. Kolone matrice čine termini, a elementi odgovaraju frekvencijama svakog termina u određenoj twitter poruci. Za kreiranje DTM koristimo ugrađenu funkciju DocumentTermMatrix iz biblioteke tm. 


###Particionisanje podataka

Kostićemo funkciju createDataPartition() da  podelimo dati dataset na deo za trening i deo za testiranje prema razmeri 80:20.
Treniraćemo Naïve Bayes klasifikator na trening dataset-u a zatim njegove performance proveriti na test dataset-u. Trenutna proporcija pozitivnih i negativnih poruka iznosti 50:50. 
Proverićemo da je tokom postupka particionisanja sačuvana ista proporcija u delu za trening i obuku. Kako bismo to proverili kreirana je dodatna funkcija frqtab().


Slika 5: Provera proporcije podataka između klasa nakon particionisanja


###Selekcija atributa 

Kreirana Document-term matrica (DTM) sadrži 5372 atributa. S obzirom da nisu svi atributi korisni za klasifikaciju, izvršićemo redukciju atributa ignorišući one reči koje se pojavljuju u manje od 50 twitter poruka. 

Ograničićemo DTM da koristi samo željene reči pomoću opcije dictionary. 



Nakon selekcije atributa dimenzije matrice za trening iznose 7346 x167 dok su dimenzije matrice za testiranje 1836 x167.


###Algoritam Naivni Bajes

Naivni Bajes, algoritam za klasifikaciju teksta u suštini predstavlja primenu Bajesove teoreme, sa jakim pretpostavkama nezavisnosti. 

U ovom radu korišćena je varijacija Multinominalnog Naivnog Bajes-a koji je poznat kao binarizovani (Boolean feature) Naivni Bajes. Frekvencije termina zamenjujemo jednostavnim prisustvom tj. odsustvom određenog termina. 

Za treniranje modela korišćena je funkcija naiveBayes iz biblioteke e1071. S obzirom da Naivni Bajes izračunava proizvode verovatnoća, moramo obezbediti način da izbegnemo dodeljivanje nule onim rečima koje nisu prisutne u poruci. Zbog toda koristimo parameter laplace, koji ima vrednost 1. 



Nakon testiranja dobijenog klasifikatora na test dataset-u kreiramo matricu konfuzije sa rezultatima prikazanim na slici 6. 

Slika 6 Rezultati dobijenog klasifikatora - Naivni Bajes

###Kros validacija – Naivni Bajes

Kros validacija predstavlja postupak kojim se originalni dataset deli na k jednakih delova (eng. folds). Na taj način trening se vrši nad k-1 delova dok jedan deo preostaje za validaciju. Dati process se ponavlja k puta tako što se svaki put različiti deo koristi za validaciju. Nakon toga izračunava se prosek svih iteracija. 

Cilj kros validacije je da se spreči problem overfitting-a, a da se predikcije učine generalnijim. 
Za potrebe kros validacije, korišćena je bibliotaka caret koja pruža funkcionalnost stratifikovane kros-validacije što znači da se u svakom od dobijenih delova nalazi odgovarajuća proporcija podataka među klasama. 

Rezultati dobijenog modela kros validacijom sa podelom na 10 delova (folds=10) prikazani su na slici 7. Tačnost ovog modela Naivnog Bajesa iznosi 44.9%.






Slika 7 Rezultati kros validacije - Naivni Bajes


###Razmatranje rezultata modela Naivni Bajes

Tačnost predviđanja modela klasifikacije iskazuje se procentom ispravno predviđenih instanci u odnosu na njihov ukupan broj. 
Preciznost za ovaj model iznosi skromnih 42%. S obzirom na inače odlične performance ove metode, dobijene loše rezultate možemo jedino prepisati nereprezentativnim prikupljenim podacima. Stoga je planirani korak dalje analize ponoviti opisani postupak nad novim podacima. 


##Metoda maksimalne entropije 

Metoda maksimalne entropije predstavlja jedan od modela logističke regresije. Pripada klasi eksponencijalnih modela. Za razliku od Naivnog Bajesa, model maksimalne entropije ne pretpostavlja uslovnu nezavisnost među atributima. Metod maksimalne entropije zasniva se na principu maksimalne entropije i od svih modela koji odgovaraju trening podacima, bira onaj koji poseduje najveću entropiju. 

Ova metoda se osim za problem analize sentimenta često koristi za široku klasu problema klasifikacije teksta kao što su detekcija jezika, klasifikacija tema i druge. 


Kako bismo kreirali model maksimalne entropije koristimo biblioteku RTextTools, koja u pozadini koristi već korišćenu biblioteku e1071. Dobijene performanse algoritma prikazane su na slici 8. 


Slika 8 Performanse algoritma - MAXENT

###Kros validacija – Metoda maksimalne entropije 

Kao i kod metode Naivnog Bajesa i za metodu maksimalne entropije izvršena je kros validacija (folds=10). 
Dobijeni su sledeći rezultati:


Slika 9 Rezultati kros validacije - MAXENT





S obzirom da preciznost dobijenog modela maksimalne entropije iznosi 50.8% zaključujemo da je metod maksimalne entropije imao neznatno bolje performance od algoritma Naivni Bajes. 

##Metoda potpornih vektora

Metoda potpornih (podržavajućih) vektora predstavlja još jednu od tehnika klasifikacije. Osnovna ideja jeste naći hiper-ravan koja razdvaja podatke tako da su svi podaci jedne klase sa iste strane date ravni. 

U ovom radu korišćena je metoda potpornih vektora sa linearnim jezgrom. Zadatak treniranja podataka podrazumeva pronalazak optimalne linearne ravni koja razdvaja podatke za trening. Optimalna hiper-ravan je ona koja poseduje maksimalnu marginu odnosno rastojanje među podacima za trening. Kao rezultat dobijamo hiper-ravan koja je potpuno određena podskupom podataka za trening koji se nazivaju podržavajući (potporni) vektori. 

Na sličan način kao i kod metoda maksimalne verodostojnosti kreiran je klasifikator zasnovan na metodi potpornih vektora korišćenjem R biblioteke RTextTools.

Dobijene performance algoritma predstavljene su na slici 9.



Slika 10 Performanse algoritma - SVM

###Kros validacija – Metoda potpornih vektora 

Nakon izvršene kros validacije za model zasnovan na potpornim vektorima dobijeni su sledeći rezultati:


Slika 11 Rezultati kros validacije - SVM



##Poređenje dobijenih klasifikatora

Nakon terstiranja klasifikatora Naivni Bajes, Maksimalna entropija i metoda potpornih vektora zaključeno je da najbolje performance pruža metoda maksimalne entropije. 
Dobijene tačnosti datih algorima tokom kros validacije upoređene su u tabeli 6. 

Naivni Bajes
Maksimalna entropija
Metoda potpornih vektora
Tačnost
40.9%
50.8%
38.4%
Tabela 6  Poređenje algoritama
 

##Literatura
[1] Go A, Bhyani R, Huang L, „Twitter Sentiment Classification using Distant Supervision“, pages 1-6 
[2] Vieweg, S., Palen, L., Liu, S. B., Hughes, A. L., and Sutton, J., “Collective intelligence in disaster: An examination of the phenomenon in the aftermath of the 2007 Virginia Tech shootings.”, In Proceedings of the Information Systems for Crisis Response and Management Conference (ISCRAM). 2008.

[3] Bo Pang and Lillian Lee Sentiment analysis and opinion mining, Foundations and Tredns in Information Retrieval, Volume 2 Issue 1-2, January 2008. 
[4] B. Pang, L. Lee, and S. Vaithyanathan, Thumbs up? Sentiment classification using machine learning techniques, in Proceedings of the Conference on Empirical Methods in Natural Language Processing (EMNLP), pp. 79–86, 2002. 
