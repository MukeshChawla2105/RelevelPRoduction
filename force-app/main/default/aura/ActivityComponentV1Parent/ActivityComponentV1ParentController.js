({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.fetchTasks");
        helper.fetchEventsv1(component, event);
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allActivity = response.getReturnValue();
                allActivity.sort(function(a,b){
                  // Turn your strings into dates, and then subtract them
                  // to get a value that is either negative, positive, or zero.
                  return new Date(b.Activity_Date_Time__c) - new Date(a.Activity_Date_Time__c);
                });
                
                component.set("v.lstActivity" , allActivity); 
                
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },    
    expandAll : function(component, event) {
        debugger;
        var childCmp = component.find("cComp");
        for(var i = 0;i < childCmp.length;i++){
            childCmp[i].sampleMethod();
        }
        // childCmp.sampleMethod();
        
        component.set("v.collapse",true);
        component.set("v.expand",false);
    },
    collapseAll : function(component, event) {
        debugger;
        var childCmp = component.find("cComp");
        for(var i = 0;i < childCmp.length;i++){
            childCmp[i].sampleMethod();
        }
        
        component.set("v.collapse",false);
        component.set("v.expand",true);
    },
    isRefreshed : function(component, event,helper){
        debugger;
        window.location.reload();
        //$A.get('e.force:refreshView').fire()
        //doInit:(component, event,helper);
    }
})