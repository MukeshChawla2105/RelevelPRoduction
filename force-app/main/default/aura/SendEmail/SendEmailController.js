({
    doInit: function(component, event, helper) {
        var action = component.get("c.fetchLeadDetails");
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                debugger;
                var serverResponse = response.getReturnValue();
                component.set("v.emailId",serverResponse.Email);
                component.set("v.TemplateName",serverResponse.emailTemplateName);
                component.set("v.emailTemps",serverResponse.emailTemplateList);
              
                for(var i=0;i<serverResponse.emailTemplateList.length;i++){
                    if(serverResponse.emailTemplateList[i].Name == component.get("v.selectedValue")){
                        component.set("v.subject", serverResponse.emailTemplateList[i].Subject);
                        component.set("v.myMessage", serverResponse.emailTemplateList[i].HtmlValue);
                    }   
                }
            } else{
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    Send : function(component, event, helper) {
        var email=helper._e('txtEmail').value;
        var Subject=helper._e('txtSubject').value;
        var Message=component.get("v.myMessage");        
        //var regExpEmailformat = "/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/"; 
        
        if(email==''){
            alert('Email-Id is required');
        }
        else if(Subject==''){
            alert('Subject is required');
        }
            else if(Message==''){
                alert('Message is required');
            }
                else{
                    /*if(!email.match(regExpEmailformat)){
                        alert("Invalid Email Id");
                    }
                    else{
                      */ helper.SendEmail(component);
                }
    },
    
    showSpinner: function(component, event, helper) {        
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){        
        component.set("v.Spinner", false);
    },
    onChange: function (component,event,helper) {
        debugger;
        var emailTemplateSelected = component.find('select').get('v.value');
        var emailTemplateList = component.get("v.emailTemps");
        for(var i=0;i<emailTemplateList.length;i++){
            if(emailTemplateList[i].Name == emailTemplateSelected){
                component.set("v.subject", emailTemplateList[i].Subject);
                component.set("v.myMessage", emailTemplateList[i].HtmlValue);
            }   
        }
    }
})