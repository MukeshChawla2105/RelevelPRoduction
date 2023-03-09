({
    doInit: function(component, event, helper) {
        
        debugger;
        var currentRecordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        
        action.setParams({
            RecordId : currentRecordId
            
        });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS"){
                debugger;
                var ServerResponse = response.getReturnValue();
                component.set("v.allMapValues",ServerResponse.MapofPickListbyValue); //
                var map1 = [];
                for ( var key in ServerResponse.MapofCAuditFieldbyValue ) {
                    map1.push({value:ServerResponse.MapofCAuditFieldbyValue[key], key:key});
                }
                //const map1 = new Map(Object.entries(ServerResponse.MapofCAuditFieldbyValue));
                component.set("v.ObjectMapCustomPicklist",map1);
                var a = component.get('c.doInitTemp');
                $A.enqueueAction(a);
                
                
            } 
        });
        $A.enqueueAction(action);
        
    },
    doInitTemp: function(component, event, helper) {
        debugger;
        var currentRecordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        
        action.setParams({
            RecordId : currentRecordId
            
        });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS"){
                debugger;
                var ServerResponse = response.getReturnValue();
                var leadwithQualityScore ={};
                if(ServerResponse.leadRecWithQualityScore.length>0){
                    if(ServerResponse.leadRecWithQualityScore[0].Quality_Score__r != null)
                        leadwithQualityScore = ServerResponse.leadRecWithQualityScore[0].Quality_Score__r[0];
                }
                
                component.set("v.QualityScore", leadwithQualityScore);
                component.set("v.disableEdit", ServerResponse.leadRecWithQualityScore[0].isQualityScoreUpdated__c);
                if(ServerResponse.leadRecWithQualityScore[0].Quality_Score__r[0].Sale_Validity__c == 'Invalid')
                    component.set("v.showInvalidReason", true);         
                if(ServerResponse.leadRecWithQualityScore[0].Quality_Score__r[0].Sale_Validity__c == 'Could not be determined')
                    component.set("v.showCouldNotDeterminedReason", true);         
                if(ServerResponse.leadRecWithQualityScore[0].Quality_Score__r[0].Reason_for_Invalid__c == 'Others')
                    component.set("v.invalidReasonOthers", true);         
                
                
            } 
        });
        $A.enqueueAction(action);
    },
    
    SaveQualityScore : function(component, event, helper) {
        
        debugger;
        var action = component.get("c.SaveQualityScoreDetails");
        var QualityScoreForJS = component.get('v.QualityScore');
        component.set("v.disableEdit", true);
        var currentRecordId = component.get("v.recordId");
        QualityScoreForJS.Lead__c = currentRecordId;
        //var tempQualityScore = [];
        //tempQualityScore.push(QualityScoreForJS);
        //tempQualityScore.push[{'Lead__c': currentRecordId}];
        
        action.setParams({
            QualityScore : QualityScoreForJS
            
        });
        
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS"){
                debugger;
                var serverResponse = response.getReturnValue();
                component.set("v.allMapValues",response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Audit Form Submitted',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else{
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
        });
        
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
        $A.enqueueAction(action);
        
    },
    saleVAlidityChanged : function(component, event, helper) {
        
        debugger;
        var selectedValue = component.find('saleValidity').get('v.value');
        if(selectedValue == 'Invalid'){
            debugger;
            component.set("v.showInvalidReason", true);         
            component.set("v.showCouldNotDeterminedReason", false);
            component.set("v.invalidReasonOthers", false);
        }
        if(selectedValue == 'Could not be determined'){
            debugger;
            component.set("v.showCouldNotDeterminedReason", true);
            component.set("v.showInvalidReason", false);
            component.set("v.invalidReasonOthers", false);
        }
        if(selectedValue == 'Valid'){
            debugger;
            component.set("v.showCouldNotDeterminedReason", false);
            component.set("v.showInvalidReason", false);
        }
    },
    saleInvalidChanged : function(component, event, helper) {
        debugger;
        var selectedValue = component.find('saleInvalidChanged').get('v.value');
        if(selectedValue == 'Others'){
            component.set("v.invalidReasonOthers", true);
            component.set("v.showCouldNotDeterminedReason", false);
            
        } 
        if(selectedValue != 'Others'){
            component.set("v.invalidReasonOthers", false);
            component.set("v.showCouldNotDeterminedReason", false);
            
        } 
    }
})