@istest
public class CoreValidationTest {
	@testsetup
    static void Setup(){
        API_Configuration__c config=new API_Configuration__c(
        	ApiName__c='LastName',
            Default_Value__c='Smith',
            FieldType__c='Text',
            isRequired__c=true,
            ObjectName__c='Contact',
            PropertyName__c='Lastname',
            ValidationMessage__c='Required field',
            Name='Patient'
        );
        MasterValidation__c masterValidation=new  MasterValidation__c(
        	Name='OnlyCharacters',
            RegexExpression__c='^[a-zA-Z]+$',
            ValidatorCallback__c='ValidationCallback.CustomRegex',
            Message__c='Only character and white spaces are allowed'
        );
        
        Insert config;
        Insert masterValidation;
        
        FieldValidation__c fldValdation=new FieldValidation__c(
        	AppField__c=config.Id,
            ValidationType__c=masterValidation.Id
        );
        Insert fldValdation;
    }
    
    testmethod static void Validation(){
        test.startTest();
        string json='{"Lastname":"Sample"}';
        CoreValidation validation=new CoreValidation();
        validation.Intialize(json,'Patient');
        validation.Validate();
        validation.ValidateJson();
        test.stopTest();
    }
    
    testmethod static void FireValidation(){
        test.startTest();
        string json='{"Lastname":""}';
        CoreValidation validation=new CoreValidation();
        validation.Intialize(json,'Patient');
        validation.ValidateJson();
        test.stopTest();
    }
    
}