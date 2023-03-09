public without sharing class UserTracking{
    public UserTracking(){
    }

    
    @AuraEnabled
    public static UserTrack OnpageLoad(string userId){
        UserTrack usr = new UserTrack();
        try{
            String LoggedInUser = UserInfo.getUserId();
            list<Audit_Counsellor__c> auditCounsellorListTOUpdate = new list<Audit_Counsellor__c>();

            System.debug('LoggedInUser =====> ' + LoggedInUser);
            list<User_Tracking__c> userTracking = [select id, Checkin_Detatime__c, Checkout_Datetime__c, Member__c
                                                   from User_Tracking__c
                                                   where Member__c = :userId and CreatedDate = TODAY
                                                   limit 1];
            List<Audit_Officer__c> AuditOfficer = [SELECT AO__c, Id, IsActive__c, Name
                                                   FROM Audit_Officer__c
                                                   Where AO__c = :LoggedInUser];
            List<AO_Availability__c> AOAvailablity = [SELECT Audited_Officer__c, Audit_Officer__c, Id, Ideal_TIme__c, Meeting_Url__c, Status__c
                                                      FROM AO_Availability__c
                                                      Where Audited_Officer__c = :LoggedInUser And CreatedDate = TODAY];
            list<Audit_Counsellor__c> auditCounsellorList = [Select Id, Available__c
                                                             From Audit_Counsellor__c
                                                             where User__c = :userId];
            if (!auditCounsellorList.isEmpty()){
                for (Audit_Counsellor__c acRec : auditCounsellorList){
                    Audit_Counsellor__c acRecToUpdate = new Audit_Counsellor__c();
                    acRecToUpdate.Id = acRec.Id;
                    acRecToUpdate.Available__c = true;
                    auditCounsellorListTOUpdate.add(acRecToUpdate);
                }
                if (!auditCounsellorListTOUpdate.isEmpty()){
                    update auditCounsellorListTOUpdate;
                }
            }
            if (!AOAvailablity.isEmpty()){
                usr.AOAvailableStatus = AOAvailablity[0].Status__c;
            } else{
                AO_Availability__c emptyAOAvail = new AO_Availability__c();
                emptyAOAvail.status__c = '';
                usr.AOAvailableStatus = emptyAOAvail.Status__c;
            }

            System.debug('AuditOfficer =======> ' + AuditOfficer);
            if (!AuditOfficer.isEmpty()){
                if (AuditOfficer[0].IsActive__c == true){
                    usr.LoggedInAuditOfficer = AuditOfficer[0];
                }
            } else{
                Audit_Officer__c AO = new Audit_Officer__c();
                usr.LoggedInAuditOfficer = AO;
            }

            if (!userTracking.isEmpty()){
                //if(System.now().time() > Time.newInstance(14, 45, 00, 00))
                usr.checkin = true;
                if (userTracking[0].Checkout_Datetime__c != null){
                    System.debug('checkout ===> ');
                    usr.checkout = true;

                } else{
                    System.debug('checkout in this ===> ');
                    usr.checkout = false;
                    UserTriggerHelper.enbaleAOOnLogin(userId);
                }

            } else{
                usr.checkin = false;
                usr.checkout = true;
            }

        } catch (Exception e){
            System.debug('stack trace ======> ' + e.getStackTraceString());
        }


        return usr;
    }

    @AuraEnabled
    public static UserTrackWrapperAfterCheckin UserCheckin(string userId){
        /*if(System.now().time() < Time.newInstance(08, 59, 00, 00)){

         }else{}*/

        UserTrackWrapperAfterCheckin UserTrackWrap = new UserTrackWrapperAfterCheckin();
        String eventStatus = 'Something went wrong';
        string groupName = '';
        DateTime dt = DateTime.now();
        String dayOfWeek = dt.format('EEEE');
        if (boolean.valueOf(system.label.Enable_Sunday_Checkin)){
            if (dayOfWeek == 'Sunday'){
                eventStatus = 'You can not checkin on Sundayr.';
                //return eventStatus;
            }
        }


        if (System.now().time() < Time.newInstance(08, 59, 00, 00)){
            eventStatus = 'You can not checkin before 9:00 AM.';
            //return eventStatus;
        }

        map<string, string> mapofGroupNameBySourceIntent = new map<string, string>();
        if (userId != null){
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            /*List<AO_Availability__c> AO_AvailabilityList = new List<AO_Availability__c>();

            AO_AvailabilityList = [Select Id
                                   From AO_Availability__c
                                   where Onbehalf_AO__c = :userId and Created_Date__c = today and Status__c != 'Not Available'];

            if (!AO_AvailabilityList.isEmpty()){
                eventStatus = 'Your Manager has already logged in.';
            }
*/
            userTracking = [select id, Checkin_Detatime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and CreatedDate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c, Assignment_Group__r.name
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            List<Audit_Officer__c> AuditOfficer = [SELECT AO__c, Id, IsActive__c, Name
                                                   FROM Audit_Officer__c
                                                   Where AO__c = :userId];
            System.debug('AuditOfficer =======> ' + AuditOfficer);
            if (!AuditOfficer.isEmpty()){
                if (AuditOfficer[0].IsActive__c == true){
                    Audit_Counsellor__c AC = new Audit_Counsellor__c();
                    UserTrackWrap.AuditOfficerDetails = AuditOfficer[0];
                    UserTrackWrap.AuditcounsellorDetails = AC;
                }
            } else{
                list<Audit_Counsellor__c> AuditCounsellorlist = [SELECT Audit_Officer__c, Id, IsActive__c, Last_RRid__c, Name, User__c, Available__c
                                                                 FROM Audit_Counsellor__c
                                                                 where User__c = :userId and Available__c = false];

                if (!AuditCounsellorlist.isEmpty()){
                    for (Audit_Counsellor__c ac : AuditCounsellorlist){
                        ac.available__c = true;
                    }

                    update AuditCounsellorlist;
                }
                if (!AuditCounsellorlist.isEmpty()){
                    Audit_Officer__c AO = new Audit_Officer__c();
                    UserTrackWrap.AuditOfficerDetails = AO;
                    UserTrackWrap.AuditcounsellorDetails = AuditCounsellorlist[0];
                } else{
                    Audit_Officer__c AO = new Audit_Officer__c();
                    Audit_Counsellor__c AC = new Audit_Counsellor__c();
                    UserTrackWrap.AuditOfficerDetails = AO;
                    UserTrackWrap.AuditcounsellorDetails = AC;
                }

            }


            if (userTracking.isEmpty()){
                list<Source_Intent_And_Group_Name__mdt> groupNameSourceIntent = [select id, Group_Name__c, Source_Intent__c
                                                                                 from Source_Intent_And_Group_Name__mdt];

                if (!groupNameSourceIntent.isEmpty()){
                    for (Source_Intent_And_Group_Name__mdt signMeta : groupNameSourceIntent){
                        mapofGroupNameBySourceIntent.put(signMeta.Group_Name__c, signMeta.Source_Intent__c);
                    }
                }

                User_Tracking__c userTrackRec = new User_Tracking__c();
                userTrackRec.Member__c = userId;
                userTrackRec.Checkin_Detatime__c = DateTime.now();
                //insert userTrackRec;
                if (boolean.valueOf(system.label.leadAssignmentOnChecking)){

                    if (!agmList.isEmpty()){
                        for (Assignment_Group_Member__c agm : agmList){
                            agm.Out_Of_Office__c = false;

                        }

                        update agmList;
                        for (Assignment_Group_Member__c agm : agmList){
                            RoundRobinLeadAssignment.assignLeadsToBDS(mapofGroupNameBySourceIntent.get(agm.Assignment_Group__r.name));
                        }

                    }
                }
                if (!AuditOfficer.isEmpty()){
                    if (AuditOfficer[0].IsActive__c == true){
                        String usertrackStatus = SMMeetingLinkGenerator.MeetingUrlGenerator(userId, userTrackRec);
                    }
                    // if (usertrackStatus == 'User Track Record Created Successfully') {

                    // }
                } else{
                    insert userTrackRec;
                }
                eventStatus = 'Checkin successful';
            } else{
                eventStatus = 'Your checkin was already created.';
            }

        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }
        UserTrackWrap.eventStatus = eventStatus;
        return UserTrackWrap;
    }

    @AuraEnabled
    public static String UserCheckout(string userId){
        String eventStatus = 'Something went wrong';
        list<Audit_Counsellor__c> auditCounsellorListTOUpdate = new list<Audit_Counsellor__c>();

        if (userId != null){
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            list<Audit_Counsellor__c> auditCounsellorList = [Select Id, Available__c
                                                             From Audit_Counsellor__c
                                                             where User__c = :userId];
            if (!auditCounsellorList.isEmpty()){
                for (Audit_Counsellor__c acRec : auditCounsellorList){
                    Audit_Counsellor__c acRecToUpdate = new Audit_Counsellor__c();
                    acRecToUpdate.Id = acRec.Id;
                    acRecToUpdate.Available__c = false;
                    auditCounsellorListTOUpdate.add(acRecToUpdate);
                }
                if (!auditCounsellorListTOUpdate.isEmpty()){
                    update auditCounsellorListTOUpdate;
                }
            }
            List<AO_Availability__c> AO_OnBreak = [SELECT Audited_Officer__c, Checkin_DateTime__c, Checkout_DateTime__c, Id, Meeting_Unique_Id__c, Meeting_Url__c, Name, Status__c, Total_Idle_Time__c
                                                   FROM AO_Availability__c
                                                   Where Audited_Officer__c = :userId and CreatedDate = Today];
            userTracking = [select id, Checkin_Detatime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and createddate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            if (!userTracking.isEmpty()){
                for (User_Tracking__c ut : userTracking){
                    ut.Checkout_Datetime__c = DateTime.now();
                }
                update userTracking;
                //Database.SaveResult[] srList = Database.insert(userTracking, false);
                if (userTracking[0].Checkin_Detatime__c != null && !AO_OnBreak.isEmpty()){
                    AO_OnBreak[0].status__c = 'Not Available';
                    AO_OnBreak[0].Checkout_DateTime__c = DateTime.now();
                    update AO_OnBreak[0];
                }
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agm : agmList){
                        agm.Out_Of_Office__c = true;
                    }

                    update agmList;
                }

                eventStatus = 'Checkout datetime has been updated.';
            } else{
                eventStatus = 'You can not checkout without checkin.';
            }

        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }


        return eventStatus;
    }

    @AuraEnabled
    public static String BreakTime(string userId, string buttonlabel){
        System.debug('userId ======> ' + userId);
        System.debug('buttonlabel ======> ' + buttonlabel);
        string Message = '';
        try{
            List<AO_Availability__c> AO_OnBreak = [SELECT Audited_Officer__c, Checkin_DateTime__c, Checkout_DateTime__c, Id, Meeting_Unique_Id__c, Meeting_Url__c, Name, Status__c, Total_Idle_Time__c
                                                   FROM AO_Availability__c
                                                   Where Audited_Officer__c = :userId and CreatedDate = Today];

            if (!AO_OnBreak.isEmpty()){
                if (buttonlabel == 'Start Break Time' && AO_OnBreak[0].Status__c == 'In Meeting'){
                    Message = 'Please fill out Interview Feedback before marking yourself on Break!!!';
                } else if (buttonlabel == 'Start Break Time'){
                    AO_OnBreak[0].Status__c = 'On Break';
                    AO_OnBreak[0].Break_Start_Time__c = System.now();
                    Message = 'Break Time Started';
                    System.debug('AO_OnBreak[0] =====> ' + AO_OnBreak[0]);
                    update AO_OnBreak[0];
                    /*User_tracking__c userTrackingRec = new User_tracking__c();
                    userTrackingRec.Id = [Select Id
                                          From User_tracking__c
                                          Where Member__c = :userId and Check_in_Date__c = today].Id;
                    userTrackingRec.On_Break__c = 'yes';
                    update userTrackingRec;*/
                } else if (buttonlabel == 'End Break Time'){
                    AO_OnBreak[0].Status__c = 'Available';
                    AO_OnBreak[0].Break_End_Time__c = System.now();
                    Message = 'Break Time Ended';
                    System.debug('AO_OnBreak[0] =====> ' + AO_OnBreak[0]);
                    update AO_OnBreak[0];
                   /* User_tracking__c userTrackingRec = new User_tracking__c();
                    userTrackingRec.Id = [Select Id
                                          From User_tracking__c
                                          Where Member__c = :userId and Check_in_Date__c = today].Id;
                    userTrackingRec.On_Break__c = 'No';
                    update userTrackingRec;*/
                }

            }

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return Message;
    }

    @AuraEnabled
    public static String MeetingStarted(string userId, string buttonlabel){
        string Message = '';
        try{
            List<AO_Availability__c> AO_OnBreak = [SELECT Audited_Officer__c, Checkin_DateTime__c, Checkout_DateTime__c, Id, Meeting_Unique_Id__c, Meeting_Url__c, Name, Status__c, Total_Idle_Time__c
                                                   FROM AO_Availability__c
                                                   Where Audited_Officer__c = :userId and CreatedDate = Today];
            System.debug('AO_OnBreak =====> ' + AO_OnBreak);
            if (!AO_OnBreak.isEmpty()){
                if (buttonlabel == 'Start Meeting'){
                    AO_OnBreak[0].Status__c = 'In Meeting';
                    Message = 'Meeting is Started';
                } else if (buttonlabel == 'End Meeting'){
                    AO_OnBreak[0].Status__c = 'Available';
                    Message = 'Meeting is Ended';
                }
                System.debug('AO_OnBreak[0] =====> ' + AO_OnBreak[0]);
                update AO_OnBreak[0];
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return Message;
    }

    public class UserTrack{
        @AuraEnabled
        public boolean checkin;
        @AuraEnabled
        public boolean checkout;
        @AuraEnabled
        public Audit_Officer__c LoggedInAuditOfficer;
        @AuraEnabled
        public String AOAvailableStatus;
    }

    public class UserTrackWrapperAfterCheckin{
        @AuraEnabled
        public String eventStatus;
        @AuraEnabled
        public Audit_Officer__c AuditOfficerDetails;
        @AuraEnabled
        public Audit_Counsellor__c AuditcounsellorDetails;

    }

}