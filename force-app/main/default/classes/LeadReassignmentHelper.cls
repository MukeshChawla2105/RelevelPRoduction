public without sharing class LeadReassignmentHelper {
    @auraEnabled
    public static void updateLeadDetails(string leadRec){
        try{
               system.debug('leadRec::'+leadRec);
        if(!String.isBlank(leadRec)){
            Lead leadRecToBeUpdated = [Select id,OwnerId,Learner_Uid__c from Lead Where Id = : leadRec];
            system.debug('lead.Goal ::'+leadRecToBeUpdated.OwnerId );
            string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Relevel Default Queue' limit 1].Id;
            system.debug('queueId::'+queueId);
            leadRecToBeUpdated.OwnerId = queueId;
            update leadRecToBeUpdated;
            system.debug('lead.Goal ::'+leadRecToBeUpdated.OwnerId);
            String courseInterested = [Select Goal_Interested_In__c From Lead Where Id =: leadRec limit 1].Goal_Interested_In__c;
            if(!String.isBlank(courseInterested)){
                RoundRobinLeadAssignment.assignLeadsToBDS(courseInterested);
            }
        } 
        }catch(exception ex){
            system.debug('Error>>'+ex.getMessage());
            system.debug('Err@@>>'+ex.getLineNumber());
                
        }
    
    }    
}