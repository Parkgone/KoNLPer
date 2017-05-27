library(reticulate, lib.loc = "/usr/local/lib/R/site-library")
library(KoNLP, lib.loc = "/usr/local/lib/R/site-library")
library(stringi)
library(jsonlite)

useNIADic()
useSejongDic()
buildDictionary(ext_dic = "woorimalsam")

flask = import('flask')
app = flask$Flask('__main__')

funcList<-c("HangulAutomata",
            "MorphAnalyzer",
            "SimplePos09",
            "SimplePos22",
            "concordance_file",
            "concordance_str",
            "convertHangulStringToJamos",
            "convertHangulStringToKeyStrokes",
            "extractNoun",
            "is.ascii",
            "is.hangul",
            "is.jaeum",
            "is.jamo",
            "is.moeum",
            "mutualinformation")

to_character<-function(x){
  res<-py_unicode(x)
  res<-as.character(res)
  return(res)
}

index = function() {
  input<-flask$request$form
  input<-py_to_r(input)
  if(!identical(input$method,NULL)){
    return(jsonlite::toJSON(list(functions=funcList)))
  }
  if(identical(input$message,NULL)){
    return("please add param message.")
  }
  if(identical(input$call,NULL)){
    return("please add param call.")
  }
  if(identical(input$output,NULL)){
    output<-"all"
  }
  out1<-input$output[1]
  if(out1 %in% c("only","all")){
    output<-out1
    rm(out1)
  }
  message<-to_character(input$message[1])
  if(nchar(message)==0){
    return("please add message over length 0.")
  }
  call<-to_character(input$call[1])
  if(!call %in% funcList){
    return(paste0("no function available: ",call,
                  "\nplease check available function list.\n",
                  "req {method: ''}"))
  }
  result<-do.call(call,list(message))
  print(result)
  if(output=="only"){
    out<-jsonlite::toJSON(list(result=result))    
  }
  if(output=="all"){
  out<-jsonlite::toJSON(list(message=message,
                             call=call,
                             result=result))
  }
  return(out)
}

app$add_url_rule('/', 
                 methods=list("POST"),
                 view_func = index)

app$run(host="0.0.0.0",port=5000)