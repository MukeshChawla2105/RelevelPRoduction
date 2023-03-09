({
	doInit : function(component, event, helper) {
        
        debugger;
        component.set("v.showSpinner", true);
		var currentRecId = component.get('v.recordId');
        var action = component.get('c.queryEventRec'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "eventId" : currentRecId 
        });
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                var serverResponse = response.getReturnValue();

                if(serverResponse =='Events Details processing is in Progress! Recording Processing is also In progress!' || serverResponse == null){
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: ' Try after sometime Recording And Event Details Processing is in Progress',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        component.set("v.showSpinner", false);
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        //$A.get('e.force:refreshView').fire();

                }
                else if(serverResponse =='Event Record not found!'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Some Error has Occurred!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set("v.showSpinner", false);
                    $A.get('e.force:refreshView').fire();

                }
                else if(serverResponse =='Recording link not found'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Recording was not started by Executive and Rest of the Details have been Updated!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set("v.showSpinner", false);
                    $A.get('e.force:refreshView').fire();

                }
                
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Recording details have been updated successfully!!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set("v.showSpinner", false);
                    $A.get('e.force:refreshView').fire();
                }
                //component.set('v.sObjList', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})