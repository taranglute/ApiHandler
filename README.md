# ApiHandler
ApiHandler eases your tasks of validating JSON value attribute and returning the deserialized object which can be either processed for further actions or can be directly inserted into the Salesforce. In Rest API and many other API, JSON is the format used to share data. 
Json is a human-readable text consisting of attributes, keys and values. So validating JSON values is very important. Let's take a look
at the usual implementation, we follow while working with API.

### Validating Incoming Data
------------------------------------------------------
In API implementation, validating incoming data is very important. Below are some of the common validations.
  1. **Required Field** - Validating if required keys have values or not.
  2. **Format Checking** -  Validating if values are in the correct format or not. **For example: Email-Id**.
  3. **Typecasting** - Converting value type from one format to other. **For example- Integer to String**.

### Deserializing JSON to Object-
-------------------------------------------------------
Another important task is to deserialize valid JSON to an object. This object can be further used to perform activities like storing in DB.A common approach to creating an object is creating a wrapper and casting Json to the wrapper. Below are some of the problems we face with the wrapper.
  1. **Creating Wrapper** - In the case of multiple API, creating a wrapper for each API is not a good idea.
  2. **Managing Wrapper** - Managing fields i.e adding field or removing field or renaming field is tedious job.

### Getting Started with ApiHandler
-------------------------------------------------------
API handler is driven by below three main objects -
1. **API Configuration**- This object holds the core mapping details between incoming or passed JSON versus SObject fields.
2. **FieldValidation**-  This is the Junction object between app validation and MasterValidation, to specify custom field level validation.
3. **MasterValidation**- This is a master object which stores custom validation with the error message, regex expression, and callback method

### Quick Guide
---------------------------------------------------------
#### Creating Configuration Record
Say you have Rest API know as *ContactAPI* to create a new contact. 
Sample JSON for same.
```
{
    "FirstName" : "Alex",
    "LastName" : "Smith”,
    "Email" : "Alex.Smith@ymail.com"
}
```
**Sample Salesforce Record**

![Configuration](screenshots/Configuration.png?raw=true "Configuration")

Map all JSON properties with Contact fields. For that, create records in AppValidation object for all JSON Properties.
**Note**
  - When we create record for each json properties name field should be same i.e *ContactAPI*
  - If you are marking field as isRequired then provide validation message as well.

**Sample record for multiple keys**

![Configuration](screenshots/Configuration2.png?raw=true "Configuration")

#### Adding multiple validation for fields
Normally, we execute multiple validations for a JSON value. Email id is the common example where we check email formatting. This can be easily handled in API handler. To add multiple validations against a key, create a record in field validation object. This is a junction object of field id vs master validation id.
  - **AppField** - Master-detail relationship between FieldValidation and AppValidation.
  - **ValidationType**- Master-detail relationship between FieldValidation and MasterValidation

#### Creating MasterValidation Records
In the APIHandler, the user can create a set of master validations. Adding custom complex validation logic is also very easy. Below are the fields of MasterValidation objects.

  - **MasterValidation Name**- Name of master validation.
  - **RegexExpression**- Regular expression for data validation
  - **Message Error**- Error message that need to return incase of error.
  - **ValidatorCallback** - Apex method that would get invoked in order to validate field.
  
  **Sample Records in Master Validations**
 ![MasterValidations](screenshots/MasterValidations.png?raw=true "MasterValidations")
