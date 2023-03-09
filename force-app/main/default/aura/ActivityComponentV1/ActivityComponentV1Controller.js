({
    doAction : function(component, event, helper) {
        debugger;
        $A.util.toggleClass(component.find("expId"), "slds-is-open");
    },
    toggleAcitivity : function(component, event, helper) {
        
        // toggle ‘slds-is-open’ class to expand/collapse activity section
        debugger;
        $A.util.toggleClass(component.find("expId"), "slds-is-open");
        
    },   
    editTask : function(component, event) {
        debugger;
        var taskId = event.getSource().get("v.value");
        var taskRecord;
        var taskList = component.get("v.lstActivity");
        for(var i=0; i<taskList.length;i++){
            if(taskId == taskList[i].Id){
                taskRecord = taskList[i];
            }
        }
        component.set("v.taskRecord",taskRecord);
        component.set("v.editModal",true); 
        
    },
    closeModel : function(component, event) {
        debugger;
        component.set("v.editModal",false);
        component.set("v.openmodelForRecording",false);
    },
    showRecordingModal: function(component, event) {
        debugger;
        component.set("v.openmodelForRecording",true);
    },
    updateTask: function(component, event) {
        debugger;
        var action = component.get("c.updatetaskRecord");
        debugger;
        action.setParams({
            taskRec: component.get("v.taskRecord")
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
    },
})