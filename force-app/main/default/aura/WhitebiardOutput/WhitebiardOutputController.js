({
    init: function (component, event, helper) {
        debugger;
        var action = component.get("c.getWhiteBoardMarkings");
        debugger;
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                component.set("v.whiteboardMarkingList",response.getReturnValue());
            } else{
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
})