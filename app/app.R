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


app$route('/list',methods=list("GET"))({
  deliverlist<-function(){
    return(jsonlite::toJSON(list(functions=funcList)))
  }
})

app$route('/',methods=list("POST"))({
  index = function() {
    input<-flask$request$form
    input<-py_to_r(input)
    
    # treat target req
    if(identical(input$target,NULL)){
      return("please add param target.")
    }else if(length(input$target)>1){
      target<-input$target[1]
    }else{
      target<-input$target
    }
    if(nchar(target)==0){
      return("please add target over length 0.")
    }
    
    # treat call req
    if(identical(input$call,NULL)){
      return("please add param call.")
    }else if(length(input$call)>1){
      call<-input$call[1]
    }else{
      call<-input$call
    }
    if(!call %in% funcList){
      return(paste0("no function available: ",call,"\n",
                    "please check available function list.\n",
                    "GET /list"))
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
      return("output params can get only and all.")
    }
    
    result<-do.call(call,list(target))
    print(result)
    if(output=="only"){
      out<-jsonlite::toJSON(list(result=result))    
    }
    if(output=="all"){
      out<-jsonlite::toJSON(list(target=target,
                                 call=call,
                                 result=result))
    }
    return(out)
  }
})

app$run(host="0.0.0.0",port=80)