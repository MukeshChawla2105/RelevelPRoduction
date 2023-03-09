({
    handleOnLoad : function(component, event, helper) {
        debugger;
    },
    
    handleOnSubmit : function(component, event, helper) {
        debugger;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        },
    
    handleOnSuccess : function(component, event, helper) {
       
        component.set("v.reloadForm", false);
        component.set("v.reloadForm", true);
    },
    
    handleOnError : function(component, event, helper) {
        debugger;
    },
    close : function(component, event, helper) {
        debugger;
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleSave : function(component, event, helper) {
        debugger;
        var action = component.get("c.updateLeadDetails");
        debugger;
        action.setParams({
            leadRec: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                component.set("v.editModal",false);
            } else{
                debugger;
                component.set("v.editModal",false);
            }
        });
        $A.enqueueAction(action);
        
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
    },
})