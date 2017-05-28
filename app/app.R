library(reticulate, lib.loc = "/usr/local/lib/R/site-library")
library(KoNLP, lib.loc = "/usr/local/lib/R/site-library")

#useNIADic()
useSejongDic()
#buildDictionary(ext_dic = "woorimalsam")

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

functions = function() {
  input<-flask$request$form
  input<-py_to_r(input)

  # treat target req
  if(identical(input$target,NULL)){
    return(jsonlite::toJSON("please add param target."))
  }else if(length(input$target)>1){
    target<-input$target[1]
  }else{
    target<-input$target
  }
  if(nchar(target)==0){
    return(flask$json$jsonify("please add target over length 0."))
  }
  
  # treat call req
  if(identical(input$call,NULL)){
    return(flask$json$jsonify("please add param call."))
  }else if(length(input$call)>1){
    call<-input$call[1]
  }else{
    call<-input$call
  }
  if(!call %in% funcList){
    return(flask$json$jsonify(paste0("no function available: ",call,"\n",
                  "please check available function list.\n",
                  "GET /list")))
  }
  
  # treat output req
  if(identical(input$output,NULL)){
    output<-"all"
  }else if(length(input$output)>1){
    output<-input$output[1]
  }else{
    output<-input$output
  }
  if(!output %in% c("only","all")){
    return(flask$json$jsonify("output params can get only and all."))
  }
  
  result<-do.call(call,list(target))
  print(result)
  if(output=="only"){
    out<-flask$json$jsonify(list(result=result))    
  }
  if(output=="all"){
  out<-flask$json$jsonify(list(target=target,
                             call=call,
                             result=result))
  }
  return(out)
}

deliverlist<-function(){
  return(flask$json$jsonify(list(functions=funcList)))
}

index<-function(){
  return( flask$redirect("https://github.com/mrchypark/KoNLPer") )
}

app$add_url_rule('/', 'functions',
                 methods=list("POST"),
                 view_func = functions)

app$add_url_rule('/', 'index',
                 methods=list("GET"),
                 view_func = index)

app$add_url_rule('/list', 'list',
                 methods=list("GET"),
                 view_func = deliverlist)

app$run(host="0.0.0.0",port=5000)

