KoNLPer
================

introduce
---------

KoNLPer는 [reticulate](https://rstudio.github.io/reticulate/)와 [Flask](flask-docs-kr.readthedocs.io)를 이용해서 [KoNLP](https://cran.r-project.org/web/packages/KoNLP/vignettes/KoNLP-API.html)의 함수를 POST 요청으로 결과를 받을 수 있도록 구성된 R로 작성한 API 서버입니다. 성능이 뛰어나거나 대량 처리가 가능하지는 않고, java 설치 문제가 혹시 있는 분들이 테스트를 해볼 수 있는 방법을 제공해드리는데 의의를 두고 있습니다.

How to use
----------

### docker

docker image는 [mrchypark/konlper](https://hub.docker.com/r/mrchypark/konlper/)로 바로 사용 가능합니다.

    docker run -d -p 80:5000 mrchypark/konlper

`ENV`로 사전의 범위를 설정할 수 있습니다. S는 세종사전, N은 NIA사전, W는 우리샘사전입니다. `ENV=S`인 경우 세종사전 추가, `ENV=N`인 경우 NIA사전 추가입니다. `ENV=SNW`는 전체 사전 추가입니다. (로 만들고 있는 중입니다.)

### api

현재 테스트 서버가 운영중이며 [google app engine](https://appengine.google.com/)에 올리고 [duckdns.org](https://www.duckdns.org/)로 [주소](http://konlper.duckdns.org/)를 확보했습니다. 기본 url에 `GET` 요청시 현재 페이지로 리다리렉트 됩니다.

아래 쉘 명령으로 동작 가능한 함수의 리스트를 받을 수 있습니다.

    curl -X GET "http://konlper.duckdns.org/list"

R에서는 `curl`이나 `httr`에서 제공하는 함수를 바탕으로 요청할 수 있습니다.

``` r
# set url
tar<-"http://konlper.duckdns.org/list"

# curl
datc<-curl_fetch_memory(tar)
fromJSON(rawToChar(datc$content))
```

    ## $functions
    ##  [1] "HangulAutomata"                  "MorphAnalyzer"                  
    ##  [3] "SimplePos09"                     "SimplePos22"                    
    ##  [5] "concordance_file"                "concordance_str"                
    ##  [7] "convertHangulStringToJamos"      "convertHangulStringToKeyStrokes"
    ##  [9] "extractNoun"                     "is.ascii"                       
    ## [11] "is.hangul"                       "is.jaeum"                       
    ## [13] "is.jamo"                         "is.moeum"                       
    ## [15] "mutualinformation"

``` r
# httr
dath<-GET(tar)
content(dath,"parsed")
```

    ## $functions
    ## $functions[[1]]
    ## [1] "HangulAutomata"
    ## 
    ## $functions[[2]]
    ## [1] "MorphAnalyzer"
    ## 
    ## $functions[[3]]
    ## [1] "SimplePos09"
    ## 
    ## $functions[[4]]
    ## [1] "SimplePos22"
    ## 
    ## $functions[[5]]
    ## [1] "concordance_file"
    ## 
    ## $functions[[6]]
    ## [1] "concordance_str"
    ## 
    ## $functions[[7]]
    ## [1] "convertHangulStringToJamos"
    ## 
    ## $functions[[8]]
    ## [1] "convertHangulStringToKeyStrokes"
    ## 
    ## $functions[[9]]
    ## [1] "extractNoun"
    ## 
    ## $functions[[10]]
    ## [1] "is.ascii"
    ## 
    ## $functions[[11]]
    ## [1] "is.hangul"
    ## 
    ## $functions[[12]]
    ## [1] "is.jaeum"
    ## 
    ## $functions[[13]]
    ## [1] "is.jamo"
    ## 
    ## $functions[[14]]
    ## [1] "is.moeum"
    ## 
    ## $functions[[15]]
    ## [1] "mutualinformation"

[KoNLP](https://cran.r-project.org/web/packages/KoNLP/vignettes/KoNLP-API.html)를 확인해서 어떻게 사용하는지 확인하세요. 아직 옵션이 있는 함수는 제대로 동작하지 않거나 기본 옵션으로만 동작합니다.

POST에서 `form` 요청으로 결과를 JSON 형태로 받을 수 있습니다. `param` 중 `target`, `call`은 필수이고, `output`은 없으면 `all`이 기본으로 동작합니다. `all`로 진행되면 `target`, `call`, `result`로 결과를 돌려주며 `only`로 요청하면 `result`만 결과를 줍니다. `target`은 1개만 가능합니다.

``` r
# set url
tar<-"http://konlper.duckdns.org/"

# set body for POST req using httr
bodyo<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "extractNoun",
           output = "only")

# POST req
dato<-POST(tar,body = bodyo, encode = "form")

# parse result
content(dato,"parsed")
```

    ## $result
    ## $result[[1]]
    ## [1] "롯데마트"
    ## 
    ## $result[[2]]
    ## [1] "판매"
    ## 
    ## $result[[3]]
    ## [1] "흑마늘"
    ## 
    ## $result[[4]]
    ## [1] "양념"
    ## 
    ## $result[[5]]
    ## [1] "치킨"
    ## 
    ## $result[[6]]
    ## [1] "논란"

``` r
# set url
tar<-"http://konlper.duckdns.org/"

# set body for POST req using httr
bodya<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "HangulAutomata",
           output = "all")
# POST req
data<-POST(tar,body = bodya, encode = "form")

# parse result
content(data,"parsed")
```

    ## $call
    ## [1] "HangulAutomata"
    ## 
    ## $result
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

현재 세종사전만 반영되어 있습니다. 무료 티어를 사용해서 속도가 매우 느립니다.

#### 함수 사용예

KoNLP의 [공식 문서](https://cran.r-project.org/web/packages/KoNLP/vignettes/KoNLP-API.html)를 참고해 주세요.

``` r
# set url
tar<-"http://konlper.duckdns.org/"

body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "convertHangulStringToJamos",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "convertHangulStringToJamos"
    ## 
    ## $result
    ## $result[[1]]
    ## [1] "ㄹㅗㅅ"
    ## 
    ## $result[[2]]
    ## [1] "ㄷㅔ"
    ## 
    ## $result[[3]]
    ## [1] "ㅁㅏ"
    ## 
    ## $result[[4]]
    ## [1] "ㅌㅡ"
    ## 
    ## $result[[5]]
    ## [1] "ㄱㅏ"
    ## 
    ## $result[[6]]
    ## [1] " "
    ## 
    ## $result[[7]]
    ## [1] "ㅍㅏㄴ"
    ## 
    ## $result[[8]]
    ## [1] "ㅁㅐ"
    ## 
    ## $result[[9]]
    ## [1] "ㅎㅏ"
    ## 
    ## $result[[10]]
    ## [1] "ㄱㅗ"
    ## 
    ## $result[[11]]
    ## [1] " "
    ## 
    ## $result[[12]]
    ## [1] "ㅇㅣㅆ"
    ## 
    ## $result[[13]]
    ## [1] "ㄴㅡㄴ"
    ## 
    ## $result[[14]]
    ## [1] " "
    ## 
    ## $result[[15]]
    ## [1] "ㅎㅡㄱ"
    ## 
    ## $result[[16]]
    ## [1] "ㅁㅏ"
    ## 
    ## $result[[17]]
    ## [1] "ㄴㅡㄹ"
    ## 
    ## $result[[18]]
    ## [1] " "
    ## 
    ## $result[[19]]
    ## [1] "ㅇㅑㅇ"
    ## 
    ## $result[[20]]
    ## [1] "ㄴㅕㅁ"
    ## 
    ## $result[[21]]
    ## [1] " "
    ## 
    ## $result[[22]]
    ## [1] "ㅊㅣ"
    ## 
    ## $result[[23]]
    ## [1] "ㅋㅣㄴ"
    ## 
    ## $result[[24]]
    ## [1] "ㅇㅣ"
    ## 
    ## $result[[25]]
    ## [1] " "
    ## 
    ## $result[[26]]
    ## [1] "ㄴㅗㄴ"
    ## 
    ## $result[[27]]
    ## [1] "ㄹㅏㄴ"
    ## 
    ## $result[[28]]
    ## [1] "ㅇㅣ"
    ## 
    ## $result[[29]]
    ## [1] " "
    ## 
    ## $result[[30]]
    ## [1] "ㄷㅚ"
    ## 
    ## $result[[31]]
    ## [1] "ㄱㅗ"
    ## 
    ## $result[[32]]
    ## [1] " "
    ## 
    ## $result[[33]]
    ## [1] "ㅇㅣㅆ"
    ## 
    ## $result[[34]]
    ## [1] "ㄷㅏ"
    ## 
    ## $result[[35]]
    ## [1] "."
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
targ<-c()
for(i in 1:length(res$result)){
  targ <-c(targ, res$result[[i]])
}

targ<-paste(targ, collapse="")
targ
```

    ## [1] "ㄹㅗㅅㄷㅔㅁㅏㅌㅡㄱㅏ ㅍㅏㄴㅁㅐㅎㅏㄱㅗ ㅇㅣㅆㄴㅡㄴ ㅎㅡㄱㅁㅏㄴㅡㄹ ㅇㅑㅇㄴㅕㅁ ㅊㅣㅋㅣㄴㅇㅣ ㄴㅗㄴㄹㅏㄴㅇㅣ ㄷㅚㄱㅗ ㅇㅣㅆㄷㅏ."

``` r
body<-list(target = targ,
           call = "HangulAutomata",
           output = "all")
# POST req
data<-POST(tar, body = body, encode = "form")

# parse result
res<-content(data,"parsed")
res$result
```

    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "convertHangulStringToJamos",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "convertHangulStringToJamos"
    ## 
    ## $result
    ## $result[[1]]
    ## [1] "ㄹㅗㅅ"
    ## 
    ## $result[[2]]
    ## [1] "ㄷㅔ"
    ## 
    ## $result[[3]]
    ## [1] "ㅁㅏ"
    ## 
    ## $result[[4]]
    ## [1] "ㅌㅡ"
    ## 
    ## $result[[5]]
    ## [1] "ㄱㅏ"
    ## 
    ## $result[[6]]
    ## [1] " "
    ## 
    ## $result[[7]]
    ## [1] "ㅍㅏㄴ"
    ## 
    ## $result[[8]]
    ## [1] "ㅁㅐ"
    ## 
    ## $result[[9]]
    ## [1] "ㅎㅏ"
    ## 
    ## $result[[10]]
    ## [1] "ㄱㅗ"
    ## 
    ## $result[[11]]
    ## [1] " "
    ## 
    ## $result[[12]]
    ## [1] "ㅇㅣㅆ"
    ## 
    ## $result[[13]]
    ## [1] "ㄴㅡㄴ"
    ## 
    ## $result[[14]]
    ## [1] " "
    ## 
    ## $result[[15]]
    ## [1] "ㅎㅡㄱ"
    ## 
    ## $result[[16]]
    ## [1] "ㅁㅏ"
    ## 
    ## $result[[17]]
    ## [1] "ㄴㅡㄹ"
    ## 
    ## $result[[18]]
    ## [1] " "
    ## 
    ## $result[[19]]
    ## [1] "ㅇㅑㅇ"
    ## 
    ## $result[[20]]
    ## [1] "ㄴㅕㅁ"
    ## 
    ## $result[[21]]
    ## [1] " "
    ## 
    ## $result[[22]]
    ## [1] "ㅊㅣ"
    ## 
    ## $result[[23]]
    ## [1] "ㅋㅣㄴ"
    ## 
    ## $result[[24]]
    ## [1] "ㅇㅣ"
    ## 
    ## $result[[25]]
    ## [1] " "
    ## 
    ## $result[[26]]
    ## [1] "ㄴㅗㄴ"
    ## 
    ## $result[[27]]
    ## [1] "ㄹㅏㄴ"
    ## 
    ## $result[[28]]
    ## [1] "ㅇㅣ"
    ## 
    ## $result[[29]]
    ## [1] " "
    ## 
    ## $result[[30]]
    ## [1] "ㄷㅚ"
    ## 
    ## $result[[31]]
    ## [1] "ㄱㅗ"
    ## 
    ## $result[[32]]
    ## [1] " "
    ## 
    ## $result[[33]]
    ## [1] "ㅇㅣㅆ"
    ## 
    ## $result[[34]]
    ## [1] "ㄷㅏ"
    ## 
    ## $result[[35]]
    ## [1] "."
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "MorphAnalyzer",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "MorphAnalyzer"
    ## 
    ## $result
    ## $result$.
    ## $result$.[[1]]
    ## [1] "./sf"
    ## 
    ## $result$.[[2]]
    ## [1] "./sy"
    ## 
    ## 
    ## $result$논란이
    ## $result$논란이[[1]]
    ## [1] "논란/ncpa+이/jcc"
    ## 
    ## $result$논란이[[2]]
    ## [1] "논란/ncpa+이/jcs"
    ## 
    ## $result$논란이[[3]]
    ## [1] "논란/ncpa+이/ncn"
    ## 
    ## 
    ## $result$되고
    ## $result$되고[[1]]
    ## [1] "되/nbu+고/jcj"
    ## 
    ## $result$되고[[2]]
    ## [1] "되/nbu+이/jp+고/ecc"
    ## 
    ## $result$되고[[3]]
    ## [1] "되/nbu+이/jp+고/ecs"
    ## 
    ## $result$되고[[4]]
    ## [1] "되/nbu+이/jp+고/ecx"
    ## 
    ## $result$되고[[5]]
    ## [1] "되/paa+고/ecc"
    ## 
    ## $result$되고[[6]]
    ## [1] "되/paa+고/ecs"
    ## 
    ## $result$되고[[7]]
    ## [1] "되/paa+고/ecx"
    ## 
    ## $result$되고[[8]]
    ## [1] "되/pvg+고/ecc"
    ## 
    ## $result$되고[[9]]
    ## [1] "되/pvg+고/ecs"
    ## 
    ## $result$되고[[10]]
    ## [1] "되/pvg+고/ecx"
    ## 
    ## $result$되고[[11]]
    ## [1] "되/px+고/ecc"
    ## 
    ## $result$되고[[12]]
    ## [1] "되/px+고/ecs"
    ## 
    ## $result$되고[[13]]
    ## [1] "되/px+고/ecx"
    ## 
    ## 
    ## $result$롯데마트가
    ## $result$롯데마트가[[1]]
    ## [1] "롯데마트/ncn+가/jcc"
    ## 
    ## $result$롯데마트가[[2]]
    ## [1] "롯데마트/ncn+가/jcs"
    ## 
    ## 
    ## $result$양념
    ## [1] "양념/ncn"
    ## 
    ## $result$있는
    ## $result$있는[[1]]
    ## [1] "있/paa+는/etm"
    ## 
    ## $result$있는[[2]]
    ## [1] "있/px+는/etm"
    ## 
    ## 
    ## $result$있다
    ## $result$있다[[1]]
    ## [1] "있/paa+다/ef"
    ## 
    ## $result$있다[[2]]
    ## [1] "있/px+다/ef"
    ## 
    ## 
    ## $result$치킨이
    ## $result$치킨이[[1]]
    ## [1] "치킨/ncn+이/jcc"
    ## 
    ## $result$치킨이[[2]]
    ## [1] "치킨/ncn+이/jcs"
    ## 
    ## $result$치킨이[[3]]
    ## [1] "치킨/ncn+이/ncn"
    ## 
    ## 
    ## $result$판매하고
    ## $result$판매하고[[1]]
    ## [1] "판매/ncpa+하고/jcj"
    ## 
    ## $result$판매하고[[2]]
    ## [1] "판매/ncpa+하고/jct"
    ## 
    ## $result$판매하고[[3]]
    ## [1] "판매/ncpa+하/xsva+고/ecc"
    ## 
    ## $result$판매하고[[4]]
    ## [1] "판매/ncpa+하/xsva+고/ecs"
    ## 
    ## $result$판매하고[[5]]
    ## [1] "판매/ncpa+하/xsva+고/ecx"
    ## 
    ## $result$판매하고[[6]]
    ## [1] "판매/ncpa+하/xsva+어/ef+고/jcr"
    ## 
    ## 
    ## $result$흑마늘
    ## $result$흑마늘[[1]]
    ## [1] "흑마늘/ncn"
    ## 
    ## $result$흑마늘[[2]]
    ## [1] "흑마늘/nqq"
    ## 
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "SimplePos22",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "SimplePos22"
    ## 
    ## $result
    ## $result$.
    ## [1] "./SF"
    ## 
    ## $result$논란이
    ## [1] "논란/NC+이/JC"
    ## 
    ## $result$되고
    ## [1] "되/PV+고/EC"
    ## 
    ## $result$롯데마트가
    ## [1] "롯데마트/NC+가/JC"
    ## 
    ## $result$양념
    ## [1] "양념/NC"
    ## 
    ## $result$있는
    ## [1] "있/PX+는/ET"
    ## 
    ## $result$있다
    ## [1] "있/PX+다/EF"
    ## 
    ## $result$치킨이
    ## [1] "치킨/NC+이/JC"
    ## 
    ## $result$판매하고
    ## [1] "판매/NC+하고/JC"
    ## 
    ## $result$흑마늘
    ## [1] "흑마늘/NC"
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "SimplePos09",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "SimplePos09"
    ## 
    ## $result
    ## $result$.
    ## [1] "./S"
    ## 
    ## $result$논란이
    ## [1] "논란/N+이/J"
    ## 
    ## $result$되고
    ## [1] "되/P+고/E"
    ## 
    ## $result$롯데마트가
    ## [1] "롯데마트/N+가/J"
    ## 
    ## $result$양념
    ## [1] "양념/N"
    ## 
    ## $result$있는
    ## [1] "있/P+는/E"
    ## 
    ## $result$있다
    ## [1] "있/P+다/E"
    ## 
    ## $result$치킨이
    ## [1] "치킨/N+이/J"
    ## 
    ## $result$판매하고
    ## [1] "판매/N+하고/J"
    ## 
    ## $result$흑마늘
    ## [1] "흑마늘/N"
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "extractNoun",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "extractNoun"
    ## 
    ## $result
    ## $result[[1]]
    ## [1] "롯데마트"
    ## 
    ## $result[[2]]
    ## [1] "판매"
    ## 
    ## $result[[3]]
    ## [1] "흑마늘"
    ## 
    ## $result[[4]]
    ## [1] "양념"
    ## 
    ## $result[[5]]
    ## [1] "치킨"
    ## 
    ## $result[[6]]
    ## [1] "논란"
    ## 
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "is.ascii",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "is.ascii"
    ## 
    ## $result
    ## [1] FALSE
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다.",
           call = "is.hangul",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "is.hangul"
    ## 
    ## $result
    ## [1] FALSE
    ## 
    ## $target
    ## [1] "롯데마트가 판매하고 있는 흑마늘 양념 치킨이 논란이 되고 있다."

``` r
body<-list(target = "ㄹ",
           call = "is.jaeum",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "is.jaeum"
    ## 
    ## $result
    ## [1] TRUE
    ## 
    ## $target
    ## [1] "ㄹ"

``` r
body<-list(target = "ㅓ",
           call = "is.moeum",
           output = "all")
data<-POST(tar, body = body, encode = "form")

res<-content(data,"parsed")
res
```

    ## $call
    ## [1] "is.moeum"
    ## 
    ## $result
    ## [1] TRUE
    ## 
    ## $target
    ## [1] "ㅓ"
