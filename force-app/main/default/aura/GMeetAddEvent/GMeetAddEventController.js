({
    onload: function (component, event, helper) {
        debugger;
        var currentLeadId = component.get("v.recordId");
        var action = component.get("c.PassEventDetailsOnDoint");
        action.setParams({
            'LeadId': currentLeadId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.Userdetail", storeResponse.UserInfodetails);
                component.set("v.Eventrecord", storeResponse.EventRecDetail);
                component.set("v.LeadRecord", storeResponse.leadDetail);
                if (storeResponse.EventRecDetail.GMeet_Event_Id__c !== '') {
                    component.set("v.RescheduleCheckbox", true);
                    //var elements = document.getElementsByClassName("myTest");
                    //elements[0].style.display = 'block'; 
                    //$("#myTest *").attr("disabled", "disabled").off('click');
                    component.set("v.RescheduleCheckboxDateTime", true);
                    component.set("v.EmailListRecord", storeResponse.EventRecDetail.Attendees_list__c.split(','));
                }

            }
        });
        //4. Add This Method to Action
        $A.enqueueAction(action);


    },
    createAction: function (component, event, helper) {
        debugger;
        // component.set("v.disableButton", true);
        var abc = component.get("v.Eventrecord");
        var AttendeesEmaillist = component.get("v.EmailListRecord");

        var selectedAttendees = [];
        var checkvalue1 = component.find("EventCheckbox1");
        var checkvalue2 = component.find("EventCheckbox2");
        //helper.FetchLeadDetails(component, event);

        if (!Array.isArray(checkvalue1)) {
            if (checkvalue1.get("v.checked")) {
                var SMEmail = checkvalue1.get("v.name");
                //var emailCheck = this.handleIncorrectEmail((component, event, SMEmail);
                //if()
                selectedAttendees.push(checkvalue1.get("v.name"));
                //abc.IsSMInvited__c = true;

            }
        }
        if (!Array.isArray(checkvalue2)) {
            if (checkvalue2.get("v.checked")) {
                var SSMEmail = checkvalue2.get("v.name");
                selectedAttendees.push(checkvalue2.get("v.name"));
                //abc.IsSSMInvited__c = true;
            }
        }
        var emailCheckList = [];
        for (var i = 0; i < AttendeesEmaillist.length; i++) {
            var emailCheck = helper.handleIncorrectEmail(component, event, AttendeesEmaillist[i]);
            if (emailCheck == true) {
                emailCheckList.push(emailCheck);
            }

        }
        var LeadDetail = component.get("v.LeadRecord");
        if (emailCheckList.length == AttendeesEmaillist.length) {
            if (LeadDetail.Email != '') {
                component.set("v.disableButton", true);
                var currentLeadId = component.get("v.recordId");

                // 1. Get Refrence of Method
                var addEvent = component.get("c.AddEvent");

                // 2. Add parameters to Refrence Var
                addEvent.setParams({
                    'eventrecord': JSON.stringify(component.get("v.Eventrecord")),
                    'whoId': currentLeadId,
                    'attendeesEmailList': AttendeesEmaillist,
                    'SManagerEmail': SMEmail,
                    'SSManagerEmail': SSMEmail

                });

                //3. Provide Callback method
                addEvent.setCallback(this, function (response) {
                    var state = response.getState();

                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();

                        if (storeResponse == 'API Error, Please Try Again!') {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error',
                                message: 'API Response is Incorrect, Please Fill all the details correctly!',
                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'sticky'
                            });
                            toastEvent.fire();
                        }
                        else if (storeResponse == 'Event Created Successfully') {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success!',
                                message: 'Google meet link has been created Successfully!!!.',
                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                        location.reload();
                        $A.get("e.force:closeQuickAction").fire();
                    }

                });

                //4. Add This Method to Action
                $A.enqueueAction(addEvent);
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Warning',
                    message: 'Lead Email Cannot be Empty!!!',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Warning',
                message: 'Enter Valid Email Id of Attendees!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'sticky'
            });
            toastEvent.fire();
        }

    },

    handleExit: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleStartChange: function (component, event, helper) {
        debugger;
        var starttime = component.get("v.Eventrecord.StartDateTime");
        //var Endtime = component.get("v.Eventrecord.EndDateTime");

        var SartdatetimeforNow = new Date(starttime);
        var EnddatetimeforNow = SartdatetimeforNow;
        var today = new Date();
        const oneMinuteInMillis = 1 * 60 * 1000;
        var dateTocheck = today.setTime(today.getTime() - oneMinuteInMillis);

        var month;
        var date;

        if (SartdatetimeforNow.getTime() < dateTocheck) {
            alert('Start time should be greater then current time!');
            component.set("v.Eventrecord.StartDateTime", '');
            component.set("v.Eventrecord.EndDateTime", '');
            component.set("v.FieldSetBoolean", true);

        }
        else if (SartdatetimeforNow.getMonth() > today.getMonth()) {
            //alert('Month Changed');
            const diffTime = Math.abs(SartdatetimeforNow - today);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            if (diffDays > 4) {
                alert('Interview Cannot be scheduled for Future Days(T+4) T= Today')
                component.set("v.Eventrecord.StartDateTime", '');
                component.set("v.Eventrecord.EndDateTime", '');
                component.set("v.FieldSetBoolean", true);
            }
            else {
                if (SartdatetimeforNow.getMinutes() > 0 && SartdatetimeforNow.getMinutes() <= 9) {
                    SartdatetimeforNow.setMinutes(10);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(20);
                    //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                } else if (SartdatetimeforNow.getMinutes() > 10 && SartdatetimeforNow.getMinutes() <= 19) {
                    SartdatetimeforNow.setMinutes(20);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(30);
                    //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                } else if (SartdatetimeforNow.getMinutes() > 20 && SartdatetimeforNow.getMinutes() <= 29) {
                    SartdatetimeforNow.setMinutes(30);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(40);
                    //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                } else if (SartdatetimeforNow.getMinutes() > 30 && SartdatetimeforNow.getMinutes() <= 39) {
                    SartdatetimeforNow.setMinutes(40);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(50);
                    //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                } else if (SartdatetimeforNow.getMinutes() > 40 && SartdatetimeforNow.getMinutes() <= 49) {
                    SartdatetimeforNow.setMinutes(50);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(0);
                    EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                } else if (SartdatetimeforNow.getMinutes() > 50 && SartdatetimeforNow.getMinutes() <= 59) {
                    SartdatetimeforNow.setMinutes(0);
                    SartdatetimeforNow.setHours(SartdatetimeforNow.getHours() + 1);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.setMinutes(10);
                    EnddatetimeforNow.setHours(EnddatetimeforNow.getHours());

                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                }
                /*else if(SartdatetimeforNow.getMinutes() > 30 && SartdatetimeforNow.getMinutes() <= 59){
                    SartdatetimeforNow.setMinutes(60);
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);
                    EnddatetimeforNow.setMinutes(SartdatetimeforNow.getMinutes() + 30);
                    EnddatetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
    
                }*/
                else {
                    SartdatetimeforNow.toISOString();
                    component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                    EnddatetimeforNow.toISOString(EnddatetimeforNow.setMinutes(EnddatetimeforNow.getMinutes() + 10));
                    component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);
                }

                /*datetimeforNow.setMinutes(datetimeforNow.getMinutes() + 30);
                    datetimeforNow.toISOString();
                    component.set("v.Eventrecord.EndDateTime", datetimeforNow.toISOString());
                    component.set("v.FieldSetBoolean", false);*/

            }
        }
        else if (SartdatetimeforNow.getDate() > today.getDate() + 3) {
            alert('Interview Cannot be scheduled for Future Days(T+4) T= Today');
            component.set("v.Eventrecord.StartDateTime", '');
            component.set("v.Eventrecord.EndDateTime", '');
            component.set("v.FieldSetBoolean", true);
        }
        else if (SartdatetimeforNow.getDay() == 0) {
            alert('Inteview cannot be Scheduled For sunday!');
            component.set("v.Eventrecord.StartDateTime", '');
            component.set("v.Eventrecord.EndDateTime", '');
            component.set("v.FieldSetBoolean", true);
        }
        else {
            if (SartdatetimeforNow.getMinutes() > 0 && SartdatetimeforNow.getMinutes() <= 9) {
                SartdatetimeforNow.setMinutes(10);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(20);
                //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            } else if (SartdatetimeforNow.getMinutes() > 10 && SartdatetimeforNow.getMinutes() <= 19) {
                SartdatetimeforNow.setMinutes(20);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(30);
                //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            } else if (SartdatetimeforNow.getMinutes() > 20 && SartdatetimeforNow.getMinutes() <= 29) {
                SartdatetimeforNow.setMinutes(30);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(40);
                //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            } else if (SartdatetimeforNow.getMinutes() > 30 && SartdatetimeforNow.getMinutes() <= 39) {
                SartdatetimeforNow.setMinutes(40);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(50);
                //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            } else if (SartdatetimeforNow.getMinutes() > 40 && SartdatetimeforNow.getMinutes() <= 49) {
                SartdatetimeforNow.setMinutes(50);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(0);
                EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            } else if (SartdatetimeforNow.getMinutes() > 50 && SartdatetimeforNow.getMinutes() <= 59) {
                SartdatetimeforNow.setMinutes(0);
                SartdatetimeforNow.setHours(SartdatetimeforNow.getHours() + 1);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.setMinutes(10);
                EnddatetimeforNow.setHours(EnddatetimeforNow.getHours());

                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            }
            /*else if(SartdatetimeforNow.getMinutes() > 30 && SartdatetimeforNow.getMinutes() <= 59){
                SartdatetimeforNow.setMinutes(60);
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                //EnddatetimeforNow.setHours(EnddatetimeforNow.getHours() + 1);
                EnddatetimeforNow.setMinutes(SartdatetimeforNow.getMinutes() + 30);
                EnddatetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);

            }*/
            else {
                SartdatetimeforNow.toISOString();
                component.set("v.Eventrecord.StartDateTime", SartdatetimeforNow.toISOString());
                EnddatetimeforNow.toISOString(EnddatetimeforNow.setMinutes(EnddatetimeforNow.getMinutes() + 10));
                component.set("v.Eventrecord.EndDateTime", EnddatetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);
            }

            /*datetimeforNow.setMinutes(datetimeforNow.getMinutes() + 30);
                datetimeforNow.toISOString();
                component.set("v.Eventrecord.EndDateTime", datetimeforNow.toISOString());
                component.set("v.FieldSetBoolean", false);*/

        }

    },

    RescheduleEvent: function (component, event, helper) {
        debugger;
        component.set("v.disableButton", true);
        var abc = component.get("v.Eventrecord");

        // 1. Get Refrence of Method
        var action = component.get("c.RescheduleGmeet");

        // 2. Add parameters to Refrence Var
        action.setParams({
            'UpdatedEventRec': abc,
        });

        //3. Provide Callback method
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Google meet has been Reschedulled Successfully!!!."
                });
                toastEvent.fire();
                location.reload();
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        //4. Add This Method to Action
        $A.enqueueAction(action);
    },

    AllowRescheduling: function (component, event, helper) {
        debugger;
        var checkvalue = component.find("ReSchedulecheckvalue").get("v.value");
        if (checkvalue == true) {
            component.set("v.RescheduleCheckboxDateTime", false);
        }
        else if (checkvalue == false) {
            component.set("v.RescheduleCheckboxDateTime", true);
        }
    },

    CancelEvent: function (component, event, helper) {
        debugger;
        component.set("v.disableButton", true);
        var abc = component.get("v.Eventrecord");

        // 1. Get Refrence of Method
        var EventCancellation = component.get('c.EventVanished');

        // 2. Add parameters to Refrence Var
        EventCancellation.setParams({
            'EventRec': abc,
        });

        //3. Provide Callback method

        EventCancellation.setCallback(this, function (response) {
            debugger;
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Google meet has been Cancelled Successfully!!!."
                });
                toastEvent.fire();
                location.reload();
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        //4. Add This Method to Action
        $A.enqueueAction(EventCancellation);

    },

    addEmail: function (component, event, helper) {
        debugger;
        var typedEmail = component.get("v.Email");
        var currentEmailist = component.get("v.EmailListRecord");
        // var NewEmailList = new Array();
       
        var NewEmailList = [];
        if (currentEmailist.length > 0) {
            for(var i=0; i<currentEmailist.length; i++){
                NewEmailList.push(currentEmailist[i]);
            }
            NewEmailList.push(typedEmail);

        }
        else{
            //var NewEmailList = [];
            NewEmailList.push(typedEmail);

        }

        var NewEmailistcharLengthwithComma = NewEmailList.join(',');
        if (NewEmailistcharLengthwithComma.length > 254) {
            component.set("v.EmailListRecord", currentEmailist);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Email list length is too Long!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();

            // this.LightningAlert.open({
            //     message: 'Email list length is too Long!!',
            //     theme: 'error',
            //     label: 'Error!',
            // }).then(function() {
            //     console.log('alert is closed');
            // });

        }
        else {
            component.set("v.EmailListRecord", NewEmailList);
        }
        component.find("inputfield").set("v.value", "");
    },

    handleRemove: function (cmp, event) {
        event.preventDefault();
        alert('Remove button was clicked!');
    },
    handleClick: function (component, event, helper) {
        //event.preventDefault();
        //alert('Remove button was clicked!');
        debugger;
        var pillId = event.getSource().get("v.name");
        var pills = component.get("v.EmailListRecord");

        for (var i = 0; i < pills.length; i++) {
            if (pillId === i) {
                pills.splice(i, 1);
                break;
            }
        }

        component.set('v.EmailListRecord', pills);

    },

    CheckAvailableSlot: function (component, event, helper) {
        debugger;
        helper.showSpinner(component);
        var StartTimeForGmeet = component.get("v.Eventrecord.StartDateTime");
        var EndTimeForGmeet = component.get("v.Eventrecord.EndDateTime");
        var EmailforGeetMeet;
        var SMEmail;
        var SSMEmail;
        var checkvalue1 = component.find("EventCheckbox1");
        var checkvalue2 = component.find("EventCheckbox2");
        //helper.FetchLeadDetails(component, event);

        if (!Array.isArray(checkvalue1)) {
            if (checkvalue1.get("v.checked")) {
                if (StartTimeForGmeet != null && EndTimeForGmeet != null) {
                    SMEmail = checkvalue1.get("v.name");
                    var action = component.get("c.CheckAvailableSlotFromAPI");
                    action.setParams({
                        'StartTime': StartTimeForGmeet,
                        'EndTime': EndTimeForGmeet,
                        'Email': SMEmail
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();

                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();
                            component.set("v.BookedAndAvailbleSlots", storeResponse);
                            helper.hideSpinner(component);
                            if (storeResponse != null) {
                                component.set("v.AvailableSlots", true);
                            }
                        }
                    });
                    //4. Add This Method to Action
                    $A.enqueueAction(action);

                } else {

                    //component.set("v.Eventrecord.IsSMInvited__c", false);
                    helper.hideSpinner(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Start Date Time and End Date Time cannot be Empty!!!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    return;

                }

            }
            else {
                helper.hideSpinner(component);
            }
        }

    },

    CheckAvailableSlotforSSM: function (component, event, helper) {
        debugger;
        helper.showSpinner(component);
        var StartTimeForGmeet = component.get("v.Eventrecord.StartDateTime");
        var EndTimeForGmeet = component.get("v.Eventrecord.EndDateTime");
        var EmailforGeetMeet;
        var SMEmail;
        var SSMEmail;
        var checkvalue1 = component.find("EventCheckbox1");
        var checkvalue2 = component.find("EventCheckbox2");
        //helper.FetchLeadDetails(component, event);
        if (!Array.isArray(checkvalue2)) {
            if (checkvalue2.get("v.checked")) {
                if (StartTimeForGmeet != null && EndTimeForGmeet != null) {
                    SSMEmail = checkvalue2.get("v.name");
                    var action = component.get("c.CheckAvailableSlotFromAPI");
                    action.setParams({
                        'StartTime': StartTimeForGmeet,
                        'EndTime': EndTimeForGmeet,
                        'Email': SSMEmail
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();

                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();
                            component.set("v.BookedAndAvailbleSlots", storeResponse);
                            helper.hideSpinner(component);
                            if (storeResponse != null) {
                                component.set("v.AvailableSlots", true);
                            }
                        }
                    });
                    //4. Add This Method to Action
                    $A.enqueueAction(action);

                }
                else {
                    component.set("v.Eventrecord.IsSSMInvited__c", false);
                    helper.hideSpinner(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Start Date Time and End Date Time cannot be Empty!!!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }


            }
            else {
                helper.hideSpinner(component);

            }
        }
    },

    viewAllSlot: function (component, event, helper) {
        component.set("v.AvailableSlots", true);
    },

    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.AvailableSlots", false);
    },

    handleEndChange: function (component, event, helper) {
        debugger;
        var enddatetime = component.get("v.Eventrecord.EndDateTime");
        var EnddatetimeforNow = new Date(enddatetime);
        var enddatetimeInMs = EnddatetimeforNow.getTime();
        var startdatetime = component.get("v.Eventrecord.StartDateTime");
        var StartdatetimeforNow = new Date(startdatetime);
        var startdatetimeInMs = StartdatetimeforNow.getTime();
        var timediffInmin = ((enddatetimeInMs - startdatetimeInMs) / (1000 * 60));

        if (timediffInmin > 60) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Warning',
                message: 'Meeting Length cannot be Greater than 1 hour!!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'pester'
            });
            toastEvent.fire();
            enddatetimeInMs = startdatetimeInMs + 1000 * 60 * 60;
            var EnddatetimePlusOneHour = new Date(enddatetimeInMs).toISOString();
            component.set("v.Eventrecord.EndDateTime", EnddatetimePlusOneHour);
        }

        if (EnddatetimeforNow < StartdatetimeforNow) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Warning',
                message: 'End DateTime Cannot be less than Start DateTime!!!!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'pester'
            });
            toastEvent.fire();
            enddatetimeInMs = startdatetimeInMs + 1000 * 60 * 10;
            var EnddatetimePlusOneHour = new Date(enddatetimeInMs).toISOString();
            component.set("v.Eventrecord.EndDateTime", EnddatetimePlusOneHour);

        }
    },

    // handleCharLength : function (component, event, helper){
    //     var EventDescrip = component.get("v.Eventrecord.Event_Description__c");
    //     if(EventDescrip.length >255){

    //     }
    // }
})