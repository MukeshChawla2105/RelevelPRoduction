({
    doinit : function(component, event, helper) {
        debugger;
        var action = component.get("c.fetchUsersWithoutCTILicense");
        action.setCallback(this, function(response) {
            let optionsVar = [];
            if (response.getState() === "SUCCESS"){
                debugger;
                response.getReturnValue().forEach(eachRecord => {
                    optionsVar.push({ value: eachRecord.Id, label: eachRecord.Name });
            });
            component.set("v.userList",optionsVar);
        } 
                           });
        $A.enqueueAction(action);
    },
    handleChange: function(component, event, helper) {
        debugger;
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: " + selectedOptionValue.toString());
        component.set("v.selecteduserList",selectedOptionValue);
    },
   
    assignLic : function(component, event, helper) {
        debugger;
        var action = component.get("c.assignLicencesToUser");
        action.setParams({
            usersIdToAssignLicence: component.get("v.selecteduserList")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                //alert('Success');
                $A.enqueueAction(component.get('c.doinit'));
                //var a = component.get("c.doinit");
            } 
        });
        $A.enqueueAction(action);
    },
    reassignLic : function(component, event, helper) {
        debugger;
        var action = component.get("c.reassignLicences");
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                alert('Released Licences--> '+response.getReturnValue());
                $A.enqueueAction(component.get('c.doinit'));
                //var a = component.get("c.doinit");
            } 
        });
        $A.enqueueAction(action);
    },
})