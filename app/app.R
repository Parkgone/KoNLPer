library(reticulate, lib.loc = "/usr/local/lib/R/site-library")
library(KoNLP, lib.loc = "/usr/local/lib/R/site-library")
library(stringi)
library(jsonlite)

useNIADic()
useSejongDic()
buildDictionary(ext_dic = "woorimalsam")

flask = import('flask')
app = flask$Flask('__main__')

index = function() {
  input<-flask$request$form
  input<-py_to_r(input)
  message<-py_unicode(input$message)
  message<-as.character(message)
  result<-SimplePos09(message)
  print(result)
  print(class(result))
  return(jsonlite::toJSON(list(message=message,result=result)))
}

app$add_url_rule('/', 
                 methods=list("POST"),
                 view_func = index)

app$run(host="0.0.0.0",port=5000)

# 
# KoNLP::HangulAutomata()
# KoNLP::MorphAnalyzer()
# KoNLP::SimplePos09()
# KoNLP::SimplePos22()
# KoNLP::concordance_file()
# KoNLP::concordance_str()
# KoNLP::convertHangulStringToJamos()
# KoNLP::convertHangulStringToKeyStrokes()
# KoNLP::extractNoun()
# KoNLP::is.ascii()
# KoNLP::is.hangul()
# KoNLP::is.jaeum()
# KoNLP::is.jamo()
# KoNLP::is.moeum()
# KoNLP::mutualinformation()