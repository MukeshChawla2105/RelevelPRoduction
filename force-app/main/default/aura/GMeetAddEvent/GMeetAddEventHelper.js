({
    FetchLeadDetails: function (component, event, helper) {
        debugger;
        var currentLeadId = component.get("v.recordId");
        var action = component.get("c.FetchLeadDetails");
        action.setParams({
            'LeadId': currentLeadId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.LeadRecord", storeResponse);
            }
        });
        //4. Add This Method to Action
        $A.enqueueAction(action);
    },

    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    handleIncorrectEmail: function (component, event, emailtocheck) {
        debugger;
        
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(emailtocheck.match(regExpEmailformat)){
            return true;
        }
        else{
            return false;

        }

    }
})