({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getManagersInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.QueueInfo" , response.getReturnValue()); 
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
    updateLeadOwner : function(component, event, helper) {
        debugger;
        var ownerId = component.get("v.selectedValue");
        if(ownerId != null && ownerId != ""){
            var action = component.get("c.updateLeadOwnerDetails");
            action.setParams({
                leadId: component.get("v.recordId"),
                leadOwnerId : component.get("v.selectedValue")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get("e.force:closeQuickAction").fire(); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Lead Owner Updated',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else if (state === "INCOMPLETE") {
                    $A.get("e.force:closeQuickAction").fire();
                    console.log("INCOMPLETE RESPONSE");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Error Occured',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                    else if (state === "ERROR") {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'Error Occured',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error Occured: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
        }else{
            alert("Please Select Owner!"); 
        }
        
        
    },  
    onChange: function (component, event, helper) {
        debugger;
        component.set("v.selectedValue" , component.find('select').get('v.value'));
    }
})