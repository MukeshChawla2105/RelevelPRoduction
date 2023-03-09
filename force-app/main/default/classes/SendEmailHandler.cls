public class SendEmailHandler {
    @AuraEnabled
    public static string processEmail(String email, String Subject, String Message){
        String sMessage='';
        try{
            
            Lead leadName = [Select Name,Id,Goal_Interested_In__c,Course_Amount__c,Scholarship_Amount__c From Lead Where Email =: email limit 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
                mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            
            String htmlBody = Message;
            
            htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
            htmlBody = htmlBody.replace('{!Lead.Name}', leadName.Name);
            if(htmlBody.contains('{!Lead.Goal_Interested_In__c}'))
                htmlBody = htmlBody.replace('{!Lead.Goal_Interested_In__c}', leadName.Goal_Interested_In__c);
            if(htmlBody.contains('{!Lead.Course_Amount__c}'))
                htmlBody = htmlBody.replace('{!Lead.Course_Amount__c}', String.ValueOf(leadName.Course_Amount__c));
            if(htmlBody.contains('{!offerValidDate}'))
                htmlBody = htmlBody.replace('{!offerValidDate}', String.ValueOf(system.label.Offer_Valid_Till_Date));
            if(htmlBody.contains('{!Lead.Scholarship_Amount__c}'))
                htmlBody = htmlBody.replace('{!Lead.Scholarship_Amount__c}', String.ValueOf(leadName.Scholarship_Amount__c));
            
            mail.setHtmlBody(htmlBody);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
            Task tsk = new Task();
            tsk.Activity_Type__c = 'Email Interaction';
            tsk.Activity_Date_Time__c = DateTime.now();
            tsk.Status = 'Completed';
            tsk.WhoId = leadName.Id;
            tsk.Description = 'Email sent to '+leadName.Name+' regarding '+Subject+' on '+dateTime.now();
            tsk.Subject = 'Email sent to '+leadName.Name+' regarding '+Subject;
            insert tsk;
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return sMessage;
    }
    @AuraEnabled
    public static emailAndEmailTemp fetchLeadDetails(String leadId){
        List<String> templateNames = new List<String>();
        List<Email_template_Name__c> emailTemplateName = new List<Email_template_Name__c>();
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        List<Lead> leadList = New List<lead>();
        string offerValidityDate;
        
        try{  
            if(!string.isBlank(leadId)){
                leadList = [Select id,Course_Amount__c,Scholarship_Amount__c,Email From Lead Where id =:leadId limit 1 ];
                offerValidityDate = system.label.Offer_Valid_Till_Date;
            }
            
            emailTemplateName = [select Template_Name__c From Email_template_Name__c];
            
            if(!emailTemplateName.isEmpty()){
                for(Email_template_Name__c tempName : emailTemplateName){
                    templateNames.add(tempName.Template_Name__c);
                }  
                if(!templateNames.isEmpty()){
                    emailTemplates = [SELECT Body,Description,DeveloperName,HtmlValue,Name,Subject FROM EmailTemplate WHERE Name in : templateNames];
                }
            }
            if(!leadList.isEmpty() && !emailTemplates.isEmpty() && !templateNames.isEMpty() && !String.isBlank(offerValidityDate)){
                emailAndEmailTemp wrap = new emailAndEmailTemp(leadList[0].Email, emailTemplates, templateNames,leadList[0], offerValidityDate);
                return wrap;
            }
            return null;
        }catch(Exception ex){
            system.debug(ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return null;
        }
    }
    public class emailAndEmailTemp{
        @auraEnabled
        public String Email;
        @auraEnabled 
        public List<EmailTemplate> emailTemplateList;
        @auraEnabled
        public List<String> emailTemplateName;
        @auraEnabled
        public Lead leadRec;
        @auraEnabled
        public string offerValidityDate;
        
        public emailAndEmailTemp(String Email, List<EmailTemplate> emailTemplateList,List<String> emailTemplateName, Lead leadRec, string offerValidityDate){
            this.Email = Email;
            this.emailTemplateList = emailTemplateList;
            this.emailTemplateName = emailTemplateName;
            this.leadRec = leadRec;
            this.offerValidityDate = offerValidityDate;
        }
        
    }
}