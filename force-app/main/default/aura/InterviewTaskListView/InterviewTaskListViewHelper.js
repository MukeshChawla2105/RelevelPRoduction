({
    createAllAccountListListView : function(component, event, helper) {
        component.set('v.body', []);
        $A.createComponent(
            "lightning:listView",
            {
                "aura:id": "allAccountListViewId",
                "objectApiName": "Account",
                "listName": "AllAccount",
                "rows" : 10,
                "showActionBar" : false,
                "enableInlineEdit" : false,
                "showRowLevelActions" : false
            },
            function(newListView, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newListView);
                    component.set("v.body", body);                            
                } else {
                    console.log("Status: " + status + ", " + errorMessage);
                } 
            }
        );
    }
})