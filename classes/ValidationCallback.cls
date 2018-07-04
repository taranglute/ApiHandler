/*
* @Class[ValidationCallback]- Class wrapper helps to validation incoming json data.  
* @author  Tarang L
* @version 1.0 
*/
public virtual class ValidationCallback{
    
    public Boolean isMatch(string regex,string value){
        Pattern MyPattern = Pattern.compile(regex);
        Matcher MyMatcher = MyPattern.matcher(value);
        return MyMatcher.matches();
    }
    
    /*Class to validate field data aganist custom regex*/
    public class CustomRegex extends ValidationCallback implements iFieldValidate{
        public ApiWrapper.ResultWrapper ValidateField(string fieldvalue,object validation){
            ApiWrapper.ResultWrapper wrapper=new ApiWrapper.ResultWrapper();
            try{
                if(validation!=null){
                    MasterValidation__c masterval=(MasterValidation__c)validation;
                    Boolean rs= this.isMatch(masterval.RegexExpression__c,fieldvalue);
                    if(!rs){
                        wrapper.statuscode=406;
                        wrapper.Message=masterval.Message__c;
                    }
                }
            }catch(exception ex){
                throw ex;
            }
            return wrapper;
        }
    }
}