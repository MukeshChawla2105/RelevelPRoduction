({
    
    init: function(cmp, event, helper) {
        helper.setColumns(cmp);
        helper.getTaskData(cmp, event);
       window.setInterval(
            $A.getCallback(function() {
                helper.getTaskData(cmp, event);
            }), 3000
        );
    },
    
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },
    
});