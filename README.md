## ApiHandler
REST API provides a powerful and convenient API for interacting with external systems. In Rest API, JSON is the format used to share data. 
Json is a human-readable text consisting of attributes, keys and values. 

Implementation Activites 
---------------------------------------------------
Validating Data - In API implementation, validating incoming data is very important. Below are some of the common validations we do -

1. Required field - Validating if required keys have values or not.
2. Format Check -  Validating if values are in the correct format or not. For example - EmailId
3. Typecasting - Converting value type from one format to other. For example - integer to string.

Deserializing JSON to Object -
-------------------------------------------------------
Another important task is to deserialize valid JSON to object. This object can be further used to perform activities like storing in DB.
A common approach to creating an object is creating a wrapper and casting Json to the wrapper. Below are some of the problems we face with the wrapper.
1. Creating Wrapper - In the case of multiple API, creating a wrapper for each API is not a good idea.
2. Managing Wrapper - Managing fields i.e adding field or removing field or renaming field is tedious job.

