public without sharing class CounsellorsAssignmentModule {
    public CounsellorsAssignmentModule() {

    }

    public static void counsellorAssignmentLogic(List<lead> leadListOwnerTobeChanged){

        Map<String, List<String>> mapofAOIdByACIdList = new Map<String, List<String>>();
        Map<String, Integer> mapofAOIdByLastRRID = new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();

        List<Lead> leadListTobeUpdate = new list<lead>();
        List<Audit_Officer__c> QtoBeUpdated = new List<Audit_Officer__c>();
        system.debug('leadListOwnerTobeChanged::'+leadListOwnerTobeChanged);
        mapofAOIdByACIdList = makeCustomQueueNameToListOfUserId();
        system.debug('mapofAOIdByACIdList::'+mapofAOIdByACIdList);
        mapofAOIdByLastRRID = makeQNameToLastAssignedQmemberRRid();
        system.debug('mapofAOIdByLastRRID::'+mapofAOIdByLastRRID);
        QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID();
        system.debug('QnameAndRRidToMemberIDMap::'+QnameAndRRidToMemberIDMap);
		list<LeadShare> leadShareList = new list<LeadShare>();

        for(Lead ld : leadListOwnerTobeChanged){
            Boolean isAssigned = false;
            Integer qMemberSize = 1;
            

                While (mapofAOIdByACIdList != null && qMemberSize != null && mapofAOIdByACIdList.get(ld.ownerId) != null && isAssigned == false && qMemberSize <= mapofAOIdByACIdList.get(ld.ownerId).size()){
                    Integer currentRRid, LastRRid;
                    String QnameAndRRid, qMemberID;
                    system.debug('qNameToLastAssignedQmemberRRid.get(groupName)-->'+mapofAOIdByLastRRID.get(ld.ownerId));
                    if (mapofAOIdByLastRRID.get(ld.ownerId) != null)
                        LastRRid = mapofAOIdByLastRRID.get(ld.ownerId);
                    System.debug('LastRRid-------+++++' + LastRRid);
                    if (LastRRid == null || LastRRid < 1){
                        mapofAOIdByLastRRID.remove(ld.ownerId);
                        mapofAOIdByLastRRID.put(ld.ownerId, 0);
                        currentRRid = 1;
                        System.debug('Inside 1  currentRRid' + currentRRid);
                    }
                    system.debug('LastRRid::' + LastRRid);
                    system.debug('makeCustomQueueNameToListOfUserId.get(groupName).size()::' + mapofAOIdByACIdList.get(ld.ownerId).size());
                    if (LastRRid < mapofAOIdByACIdList.get(ld.ownerId).size()){
                        currentRRid = LastRRid + 1;
                        System.debug('Inside 2  currentRRid' + currentRRid);
                    } else{
                        currentRRid = 1;
                        LastRRid = 0;
                        System.debug('Inside 3  currentRRid' + currentRRid);
                    }
                    system.debug('currentRRid::'+currentRRid);
                    QnameAndRRid = ld.ownerId + String.valueOf(currentRRid);
                    system.debug('QnameAndRRid::' + QnameAndRRid);
                    system.debug('QnameAndRRidToMemberIDMap::' + QnameAndRRidToMemberIDMap);
                    qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                    System.debug('QnameAndRRid::' + QnameAndRRid);
                    System.debug('qMemberID::' + qMemberID);
                    boolean test = true;
                    if(test) {
                        system.debug('qMemberID-->'+qMemberID);
                        //qName,qMemberID,userIdbyLeadcount,ld.Learner_Uid__c,assignmentConditionSatisfied(true)
                        if (qMemberID != null){
                            LastRRid = LastRRid + 1;
                        system.debug('qNameToLastAssignedQmemberRRid-->'+mapofAOIdByLastRRID);
                        mapofAOIdByLastRRID.remove(ld.ownerId);
                        mapofAOIdByLastRRID.put(ld.ownerId, LastRRid);
                           
                            ld.ownerId = Id.valueOf(qMemberID);
                            isAssigned = true;
                            leadListTobeUpdate.add(ld);
                        }
                        system.debug('LastRRid-->'+LastRRid);
                        
                        System.debug('qNameToLastAssignedQmemberRRid::' + mapofAOIdByLastRRID);
                        qMemberSize++;
                        system.debug('qMemberSize::' + qMemberSize);
                    } else{
                        system.debug('LastRRid-->'+LastRRid);
                        LastRRid = LastRRid + 1;
                        system.debug('LastRRid-->'+LastRRid);
                        mapofAOIdByLastRRID.remove(ld.ownerId);
                        mapofAOIdByLastRRID.put(ld.ownerId, LastRRid);
                        System.debug('qNameToLastAssignedQmemberRRid::' + mapofAOIdByLastRRID);
                        qMemberSize++;
                    }
                }
        }

        if(!mapofAOIdByLastRRID.keySet().isEmpty()){
            List<Audit_Officer__c> updateQrIdToAO = new List<Audit_Officer__c>();
            updateQrIdToAO = [SELECT id,Last_RRid__c,AO__c from Audit_Officer__c where IsActive__c = true and AO__c IN: mapofAOIdByLastRRID.keySet()];
            system.debug('updateQrIdToAO::'+updateQrIdToAO);
            for(Audit_Officer__c Q: updateQrIdToAO)
            {
                Q.Last_RRid__c = mapofAOIdByLastRRID.get(Q.AO__c);
                QtoBeUpdated.add(q);
            }
        }
		system.debug('QtoBeUpdated::'+QtoBeUpdated);
        if(!QtoBeUpdated.isEmpty()){
            update QtoBeUpdated;
        }
        system.debug('leadListTobeUpdate::'+leadListTobeUpdate);
        if(!leadListTobeUpdate.isEmpty()){
            update leadListTobeUpdate;
            //insert leadShareList;
        }

    }

    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(){
        
        List<Audit_Counsellor__c> auditCounsellorList = [select id,Audit_Officer__c,IsActive__c,Last_RRid__c,User__c,Audit_Officer__r.AO__c
                                                            from Audit_Counsellor__c
                                                            where IsActive__c = true And Available__c = true and Audit_Officer__c != null];
        
        
        
        Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
        List<Assignment_Group_Member__c> listOfExistingQueueMembers = new List<Assignment_Group_Member__c>();
        
        /*listOfExistingQueueMembers = [select id, name, Out_Of_Office__c, Assignment_Group__c, Assignment_Group__r.name, Assignment_Id__c, Leave_End_Date__c, Leave_Start_Date__c, Group_Member__c, Group_Member__r.Id
                                      from Assignment_Group_Member__c
                                      where Assignment_Group__r.name = :assignmentGroupName ANd Active__c = true ];*/
        system.debug('listOfExistingQueueMembers-->'+listOfExistingQueueMembers);
        if (!auditCounsellorList.isEmpty()){
            for (Audit_Counsellor__c counsellor : auditCounsellorList){
                if (customQueueNameToListOfUserId.containsKey(counsellor.Audit_Officer__r.AO__c)){
                    customQueueNameToListOfUserId.get(counsellor.Audit_Officer__r.AO__c).add(counsellor.User__c);
                } else{
                    customQueueNameToListOfUserId.put(counsellor.Audit_Officer__r.AO__c, new list<string>{ counsellor.User__c});
                }
            }
        }
        system.debug('customQueueNameToListOfUserId::' + customQueueNameToListOfUserId);
        return customQueueNameToListOfUserId;
    }

    public static Map<String, Integer> makeQNameToLastAssignedQmemberRRid(){
        Map<String, Integer> qNameToLastAssignedQmemberRRid 		= new Map<String, Integer>();
        List<Audit_Officer__c> existingAuditRec 					= new List<Audit_Officer__c>([SELECT id,Last_RRid__c,AO__c from Audit_Officer__c where IsActive__c = true]);
        
        for(Audit_Officer__c q: existingAuditRec)
        {
            if(q.Last_RRid__c != null)
            {
                qNameToLastAssignedQmemberRRid.put(q.AO__c, Integer.valueOf(q.Last_RRid__c));    
            }
            else 
                qNameToLastAssignedQmemberRRid.put(q.AO__c, null);
        }
        return qNameToLastAssignedQmemberRRid;
    }

    public static Map<String, String> makeQnameAndRRidToMemberID(){
        //Map<String, Map<String, Integer>> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Map<String, Integer>>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        
        List<Audit_Counsellor__c> auditCounsellorList = [select id,Audit_Officer__c,IsActive__c,Last_RRid__c,User__c,Audit_Officer__r.AO__c
                                                            from Audit_Counsellor__c
                                                            where IsActive__c = true ANd Available__c = true and Audit_Officer__c != null];
        system.debug('agmList::' + auditCounsellorList);
        if (!auditCounsellorList.isEmpty()){
            for (Audit_Counsellor__c agm : auditCounsellorList){
                String qName = agm.Audit_Officer__r.AO__c;
                String qMember = string.valueOf(agm.Last_RRid__c);
                system.debug('qName::' + qName);
                system.debug('qMember::' + qMember);
                if (!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName + qMember;
                    system.debug('qNameAndQmamber::' + qNameAndQmamber);
                    QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.User__c));
                }
            }
        }
        
        System.debug('QnameAndRRidToMemberIDMap---'+QnameAndRRidToMemberIDMap);
        return QnameAndRRidToMemberIDMap;
    }
}