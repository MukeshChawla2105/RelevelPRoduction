({
    init: function(component, event, helper) {
        var action = component.get("c.captureMeetingClickTime");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                debugger;
                var url = response.getReturnValue();
                window.open(url, '_blank');
                
            } else {
                debugger;
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }    
})