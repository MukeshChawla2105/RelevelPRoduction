({
    onInit: function (component, event, helper) {
        helper.createAllAccountListListView(component, event, helper);
        window.setInterval(
            $A.getCallback(function() {
				helper.createAllAccountListListView(component, event, helper);
            }), 10000
        );    
    }
})