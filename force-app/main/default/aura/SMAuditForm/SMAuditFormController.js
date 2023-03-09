({
    loadOptions : function(component, event, helper) {
        debugger;
        var opts = [
            { value: "0", label: "0" },
            { value: "1", label: "1" },
            { value: "2", label: "2"},
            { value: "3", label: "3" },
            { value: "4", label: "4" },
            { value: "5", label: "5" },
            { value: "6", label: "6" },
            { value: "7", label: "7"},
            { value: "8", label: "8" },
            { value: "9", label: "9" },
            { value: "10", label: "10" }
        ];
        
        var minandsecToshow = [];
        /*for(var i=0; i<60; i++){
            minandsecToshow.push(i);
        }*/
        for(var i=0; i<60; i++){
            minandsecToshow.push({key: i, value: i});
            
        }
        component.set("v.StartAndEndTimeMinSec", minandsecToshow);
        component.set("v.options", opts);
        //var currentRecordId = "00Q0w0000016xnXEAQ";
        var currentRecordId = component.get("v.recordId");
        
        var action = component.get("c.getRecordOnDoint");
        action.setParams({
            'recId': currentRecordId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse.taskSize == 0 ){
                    component.set("v.emptyWrapper", true);
                }
                else if(storeResponse.taskSize > 0){
                    var callList =[];
                    for(var i=0; i<storeResponse.tasklist.length; i++){
                        //i++;
                        var string = 'Call ';
                        var newivalue = i+1;
                        var newString = string + newivalue;
                        callList.push(newString);
                    }
                    var callMap =[];
                    for(var key in callList){
                        callMap.push({key: key, value: callList[key]});
                    }
                    
                    component.set("v.AllDialledCall", callMap);
                    component.set("v.isFormFilledAlready", storeResponse.isAuditFormFilled);
                    component.set("v.MapofPickListvalue", storeResponse.MapofPickListbyValue);
                    component.set("v.SMAuditFormRecord", storeResponse.SMCallAuditRec);
                    var a = component.get('c.doInitTemp');
                    $A.enqueueAction(a);
                }
            }
        });
        // enqueue the Action 
        $A.enqueueAction(action);
    },
    
    doInitTemp: function(component, event, helper) {
        debugger;
        
        var currentRecordId = component.get("v.recordId");
        
        var action = component.get("c.getRecordOnDoint");
        action.setParams({
            'recId': currentRecordId
        });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS"){
                debugger;
                var ServerResponse = response.getReturnValue();
                var SMCallAuditFormRec ={};
                
                if(ServerResponse.SMCallAuditRec != null){
                    SMCallAuditFormRec = ServerResponse.SMCallAuditRec;
                }
                
                component.set("v.SMAuditFormRecord", SMCallAuditFormRec);
                component.set("v.isFormFilledAlready", ServerResponse.isAuditFormFilled);
                
            } 
        });
        $A.enqueueAction(action);
    },
    
    SaveSMAuditForm : function(Component, helper, event){
        debugger;
        var SMAuditFormRec = Component.get("v.SMAuditFormRecord");
        var currentRecordId = Component.get("v.recordId");
        Component.set("v.isFormFilledAlready", true);
        
        var action = Component.get("c.SaveSMAuditFormRec");
        // set param to method 
        action.setParams({
            'SMAuditRecord': SMAuditFormRec,
            'recId' : currentRecordId
        }); 
        
        // set a callBack    
        action.setCallback(this, function(response) {
            //$A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'SM Audit Form Have Been Submitted Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // if storeResponse size is equal 0 ,display No Result Found... message on screen. }
                if (storeResponse.length == 0) {
                    Component.set("v.Message", 'No Result Found...');
                } else {
                    Component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
            }        });
        // enqueue the Action
        var a = Component.get('c.doInitTemp');
        $A.enqueueAction(a);  
        $A.enqueueAction(action);
        
    },
})