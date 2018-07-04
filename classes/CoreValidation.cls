/*
* @Class[CoreValidation]- Class validated incoming json key values agnist configuration done in Salesforce.  
* @author  Tarang L
* @version 1.0 
*/
global with sharing class CoreValidation{

    public Map<String, Object> jsonInstance {get;set;}
    public Map<String, string> errorFields{get;set;}
    public static Map<String, List<MasterValidation__c>> MasterValidationMap{get;set;}
    
    Map<String, API_Configuration__c> FieldApiMap {get;set;}
    
    string ObjectName{get;set;}
    string apiRequestType{get;set;}
    
    public boolean hasFieldErrors{
        get{
            if(errorFields!=null && errorFields.size()>0){
                return true;
            }else{
                return false;
            }
        }
    }
    
    public void Intialize(string incomingJson,string requestType){
        try{
            FieldApiMap=new Map<String, API_Configuration__c>();
            errorFields=new Map<String, string>();
            apiRequestType=requestType;
            
            if(string.isNotBlank(incomingJson)){
                jsonInstance= (Map<String, Object>)JSON.deserializeUntyped(incomingJson);
                LoadFieldConfiguration(requestType);
            }
        }catch(exception ex){
            LogException('CoreValidation','Intialize',ex);
            throw ex;
        }
    }
    
    public sObject ValidateJson(){
        try{
            ValidateField(); // Run validation for each configured keys.
            if(!hasFieldErrors){
                sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                for (String fieldName : jsonInstance.keySet()){
                    object result= jsonInstance.get(fieldName);
                    API_Configuration__c apiDetails = FieldApiMap.get(fieldName.toLowerCase());
                
                    if(apiDetails != null){
                        string strResult=string.valueOf(result);
                        if(string.isBlank(strResult) && string.isNotBlank(apiDetails.Default_Value__c)){
                            result = apiDetails.Default_Value__c;
                        }
                        if(string.isNotBlank(strResult)){
                            switch on (apiDetails.FieldType__c) {
                                when 'Date' {
                                    if(string.isNotBlank(strResult)){
                                        sObj.put(apiDetails.ApiName__c,Date.parse(strResult));
                                    }
                                }
                                when 'Decimal' {
                                    sObj.put(apiDetails.ApiName__c,Decimal.valueOf(strResult));
                                }
                                when 'Number' {
                                    sObj.put(apiDetails.ApiName__c,Integer.valueOf(strResult));
                                }
                                when 'Boolean'{
                                    Boolean boolField=Boolean.valueOf(result);
                                    sObj.put(apiDetails.ApiName__c,boolField);
                                }
                                when else {
                                    system.debug('#ApiName__c -'+apiDetails.ApiName__c);
                                    sObj.put(apiDetails.ApiName__c, result);
                                }
                            }
                        }
                    }else{
                        system.debug('Validation not found for field:'+fieldName);
                    }
                }
                return sObj;
            }
            return null;
        }catch(exception ex){
            LogException('CoreValidation','ValidateJson',ex);
            throw ex;
        }
    }
    
    void ValidateField(){
        try{
            for (String key : jsonInstance.keySet()){
                string fieldname=key.toLowerCase();
                API_Configuration__c apiDetails = FieldApiMap.get(fieldname);
                if(apiDetails != null){
                    string result= String.valueOf(jsonInstance.get(key));
                    if(String.isBlank(result) && apiDetails.isRequired__c){
                        errorFields.put(fieldname,'This field is required');
                    }else{
                        //check for other validations
                        if(MasterValidationMap.containsKey(fieldname)){
                           List<MasterValidation__c> lstvalidation=MasterValidationMap.get(fieldname);
                           for(MasterValidation__c masterval:lstvalidation){
                                string callbackMethod=masterval.ValidatorCallback__c;
                                if(string.isNotBlank(callbackMethod)){
                                    Type t = Type.forName(callbackMethod);
                                    iFieldValidate newObj = (iFieldValidate)t.newInstance();
                                    ApiWrapper.ResultWrapper resultwrap= newObj.ValidateField(result,masterval);
                                    if(resultwrap!=null && resultwrap.StatusCode!=200){
                                        errorFields.put(fieldname,masterval.Message__c);
                                        break;
                                    }
                                }
                           }
                        }
                    }
                }else{
                    system.debug('Validation not found for field:'+fieldName);
                }
            }
        }catch(exception ex){
            LogException('CoreValidation','ValidateField',ex);
            throw ex;
        }
    }
    
    void LoadFieldConfiguration(string requestType){
        try{
            MasterValidationMap = new Map<String, List<MasterValidation__c>>();
            for(API_Configuration__c validation : [SELECT FieldType__c,ValidationMessage__c, PropertyName__c, ApiName__c, isRequired__c, ObjectName__c, Default_Value__c, Name,(Select ValidationType__r.Name, ValidationType__r.Message__c,ValidationType__r.RegexExpression__c,ValidationType__r.ValidatorCallback__c from FieldValidations__r) FROM API_Configuration__c where Name=:requestType])
            {
                if(String.isBlank(ObjectName)){
                   ObjectName=validation.ObjectName__c;
                }
                
                if(!FieldApiMap.containsKey(validation.PropertyName__c)){
                    FieldApiMap.put(validation.PropertyName__c.toLowerCase(),validation);
                }
                
                List<MasterValidation__c> masterValidationList=new List<MasterValidation__c>();
                if(!MasterValidationMap.containsKey(validation.PropertyName__c)){
                    list<FieldValidation__c> lstfldValidation=validation.FieldValidations__r;
                    
                    for(FieldValidation__c fcvalidation:lstfldValidation){
                       MasterValidation__c master=new MasterValidation__c(
                          Name=fcvalidation.ValidationType__r.Name,
                          Message__c=fcvalidation.ValidationType__r.Message__c,
                          RegexExpression__c=fcvalidation.ValidationType__r.RegexExpression__c,
                          ValidatorCallback__c=fcvalidation.ValidationType__r.ValidatorCallback__c
                          );
                        masterValidationList.add(master);
                    }
                    
                   MasterValidationMap.put(validation.PropertyName__c.toLowerCase(),masterValidationList);
                }
            }
        }catch(exception ex){
            LogException('CoreValidation','LoadFieldConfiguration',ex);
            throw ex;
        }
    }
    
    /*Description - Methods log exception in custom object : logger.*/
    void LogException(string classname,string methodname,exception ex){
        try{
            if(ex!=null){
                ApiLog__c logger=new ApiLog__c(
                    Classname__c=classname,
                    MethodName__c=methodname,
                    StackTrace__c=ex.getStackTraceString(),
                    LineNumber__c=ex.getLineNumber(),
                    ExceptionType__c=ex.getTypeName(),
                    Message__c=ex.getMessage()
                );
                insert logger;
            }else{
                System.debug('Exception object cannot be null.Something went wrong.');    
            }
        }catch(exception e){
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());    
        }
    }
}