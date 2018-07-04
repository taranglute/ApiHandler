global class ApiWrapper {
    
    global class ResultWrapper{
        public ResultWrapper(){
            StatusCode=CC_Literals.OK_Code;
            Message=CC_Literals.OK_Message;
        }
        public integer StatusCode{get;set;}
        public string Message{get;set;}
    }
}