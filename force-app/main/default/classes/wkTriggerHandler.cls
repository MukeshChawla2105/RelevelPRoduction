public class wkTriggerHandler {
    public static void contactTriggerController(List<Contact> contList){
        String maskingCharacter = '';
        Integer noOfDigits;   
        String maskChar = '';
        String splitPhoneNo = '';
        String phoneWithMasking = '';
        wk_exo__Exotel_Configuration__c exoConfig = [SELECT Id,wk_exo__By_Default_Create__c, wk_exo__SID__c, wk_exo__Masking_Character__c, wk_exo__Number_of_Digits__c, wk_exo__Record_Type__c FROM wk_exo__Exotel_Configuration__c LIMIT 1];
        //if(exoConfig.wk_exo__By_Default_Create__c == 'Contact'){
        if(exoConfig.wk_exo__Masking_Character__c != null && exoConfig.wk_exo__Number_of_Digits__c != null){
            maskingCharacter = exoConfig.wk_exo__Masking_Character__c;
            noOfDigits = Integer.valueOf(exoConfig.wk_exo__Number_of_Digits__c);
            for(Integer i = 0; i < noOfDigits; i++){
                maskChar = maskChar + maskingCharacter;
            }
            for(Contact con: contList){
                String originalPhoneNo = con.Phone;
                if(con.wk_exo__Clone_Pone_No__c != null && !(con.wk_exo__Clone_Pone_No__c.startsWith('*'))){
                    con.Phone = con.wk_exo__Clone_Pone_No__c;
                    originalPhoneNo = con.Phone;
                }
                if(!(originalPhoneNo.startsWith('*'))){
                    splitPhoneNo = originalPhoneNo.substring(noOfDigits, 11);
                    phoneWithMasking = maskChar+splitPhoneNo;
                    if(con.LastName.isNumeric() == true){
                        con.LastName = phoneWithMasking;
                    }
                    con.Phone = originalPhoneNo;
                    con.wk_exo__Clone_Pone_No__c = phoneWithMasking;
                    if(exoConfig.wk_exo__Record_Type__c != null){
                        con.put('RecordTypeId', exoConfig.wk_exo__Record_Type__c);
                    }    
                }                
            }
        }else{
            for(Contact con: contList){
                con.wk_exo__Clone_Pone_No__c = con.Phone;
            }
        }   
        //}
    }
    public static void leadTriggerController(List<Lead> leadList){
        String maskingCharacter = '';
        Integer noOfDigits;   
        String maskChar = '';
        String splitPhoneNo = '';
        String phoneWithMasking = '';
        /*if(test.isRunningTest()){
            
        }else{*/
            wk_exo__Exotel_Configuration__c exoConfig = [SELECT Id,wk_exo__By_Default_Create__c, wk_exo__SID__c, wk_exo__Masking_Character__c, wk_exo__Number_of_Digits__c, wk_exo__Record_Type__c FROM wk_exo__Exotel_Configuration__c LIMIT 1];
            //if(exoConfig.wk_exo__By_Default_Create__c == 'Lead'){
            if(exoConfig.wk_exo__Masking_Character__c != null && exoConfig.wk_exo__Number_of_Digits__c != null){
                maskingCharacter = exoConfig.wk_exo__Masking_Character__c;
                noOfDigits = Integer.valueOf(exoConfig.wk_exo__Number_of_Digits__c);
                for(Integer i = 0; i < noOfDigits; i++){
                    maskChar = maskChar + maskingCharacter;
                }
                for(Lead l: leadList){
                    String originalPhoneNo = l.Phone;
                    if(l.wk_exo__Clone_Pone_No__c != null && !(l.wk_exo__Clone_Pone_No__c.startsWith('*'))){
                        l.Phone = l.wk_exo__Clone_Pone_No__c;
                        originalPhoneNo = l.Phone;
                    }
                    if(originalPhoneNo!= null && !(originalPhoneNo.startsWith('*'))){
                        splitPhoneNo = originalPhoneNo.substring(noOfDigits, 11);
                        phoneWithMasking = maskChar+splitPhoneNo;
                        if(l.LastName.isNumeric() == true){
                            l.LastName = phoneWithMasking;   
                        }
                        l.Phone = originalPhoneNo;
                        l.wk_exo__Clone_Pone_No__c = phoneWithMasking;
                        if(exoConfig.wk_exo__Record_Type__c != null){
                            l.put('RecordTypeId', exoConfig.wk_exo__Record_Type__c);
                        }     
                    }              
                }
            }else{
                for(Lead l: leadList){
                    l.wk_exo__Clone_Pone_No__c = l.Phone;
                }
            }
        //}
        
        //}
    }
    public static void accountTriggerController(List<Account> accList){
        String maskingCharacter = '';
        Integer noOfDigits;   
        String maskChar = '';
        String splitPhoneNo = '';
        String phoneWithMasking = '';        
        wk_exo__Exotel_Configuration__c exoConfig = [SELECT Id, wk_exo__SID__c, wk_exo__Masking_Character__c, wk_exo__Number_of_Digits__c, wk_exo__Record_Type__c, wk_exo__By_Default_Create__c FROM wk_exo__Exotel_Configuration__c LIMIT 1];
        String defaultCreate = exoConfig.wk_exo__By_Default_Create__c;
        String query = '';
        //if(defaultCreate == 'Account'){
        if(exoConfig.wk_exo__Masking_Character__c != null && exoConfig.wk_exo__Number_of_Digits__c != null){
            maskingCharacter = exoConfig.wk_exo__Masking_Character__c;
            noOfDigits = Integer.valueOf(exoConfig.wk_exo__Number_of_Digits__c);
            for(Integer i = 0; i < noOfDigits; i++){
                maskChar = maskChar + maskingCharacter;
            }
            for(Account acc: accList){
                String originalPhoneNo = acc.Phone;
                if(acc.wk_exo__Clone_Pone_No__c != null && !(acc.wk_exo__Clone_Pone_No__c.startsWith('*'))){
                    acc.Phone = acc.wk_exo__Clone_Pone_No__c;
                    originalPhoneNo = acc.Phone;
                }
                if(!(originalPhoneNo.startsWith('*'))){
                    splitPhoneNo = originalPhoneNo.substring(noOfDigits, 11);
                    phoneWithMasking = maskChar+splitPhoneNo;
                    if(acc.Name.isNumeric() == true){
                        acc.Name = phoneWithMasking;   
                    }
                    acc.Phone = originalPhoneNo;
                    acc.wk_exo__Clone_Pone_No__c = phoneWithMasking;
                    if(exoConfig.wk_exo__Record_Type__c != null){
                        acc.put('RecordTypeId', exoConfig.wk_exo__Record_Type__c);
                    }     
                }               
            }
        }else{
            for(Account acc: accList){
                acc.wk_exo__Clone_Pone_No__c = acc.Phone;
            }
        } 
        //}
    }
}