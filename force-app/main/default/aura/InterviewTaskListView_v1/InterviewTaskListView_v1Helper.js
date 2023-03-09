({
    COLUMNS: [
        { label: 'Subject', fieldName: 'Subject' },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'DatTime',
            sortable: true,
            cellAttributes: { alignment: 'left' },
        },
        { label: 'Name', fieldName: 'Who.Name', type: 'string' },
    ],
        
        DATA: [
        { id: 1, name: 'Billy Simonns', age: 40, email: 'billy@salesforce.com' },
        { id: 2, name: 'Kelsey Denesik', age: 35, email: 'kelsey@salesforce.com' },
        { id: 3, name: 'Kyle Ruecker', age: 50, email: 'kyle@salesforce.com' },
        {
        id: 4,
        name: 'Krystina Kerluke',
        age: 37,
        email: 'krystina@salesforce.com',
        },
    ],
    
    setColumns: function (cmp) {
        cmp.set('v.columns', this.COLUMNS);
    },
    
    setData: function (cmp) {
        cmp.set('v.data', this.DATA);
    },
    
    // Used to sort the 'Age' column
    sortBy: function (field, reverse, primer) {
        var key = primer
        ? function (x) {
            return primer(x[field]);
        }
        : function (x) {
            return x[field];
        };
        
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort: function (cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        
        var cloneData = this.DATA.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },
    getTaskData: function (component, event) {
        debugger;
        var oldDataLength = 0;
        var data = component.get("v.data");
        if (data != null) {
            var oldDataLength = data.length;
            component.get("v.oldListLength", data.length);
        }
        var action = component.get("c.getAllInterviewTask");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                debugger;
                component.set("v.data", response.getReturnValue());
                debugger;
                var userId = $A.get("$SObjectType.CurrentUser.Id");
                console.log('userId:' + userId);
                //response.getReturnValue()[0].assignedTo == userId &&
                if (response.getReturnValue().length != 0 &&  response.getReturnValue()[0].status == 'Open' && response.getReturnValue()[0].beepEffect == false) {
                    setTimeout(function () {
                        debugger;
                        var getSound = $A.get('$Resource.Notification_Sound');
                        var playSound = new Audio(getSound);
                        playSound.play();
                    }, 1000);
                    // var a = component.get('c.updateSound');
                    // $A.enqueueAction(a);
                    var act = component.get("c.updateSoundField");
                    act.setParams({
                        taskwarpList : component.get("v.data")
                    });
                    act.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS"){
                            debugger;
                            
                        } else{
                            debugger;
                        }
                    });
                    $A.enqueueAction(act)
                }
            } else {
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    playAudio: function (component, event) {
        debugger;
        var getSound = $A.get('$Resource.Notification_Sound');
        var playSound = new Audio(getSound);
        playSound.play();
    },
    stopNotificationSound: function (component, event) {
        debugger;
        var action = component.get("c.updateSoundField");
        action.setParams({
            taskwarpList: component.get("v.data")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                debugger;
                
            } else {
                debugger;
            }
        });
        $A.enqueueAction(action); //var a = Component.get('c.doInitTemp'); $A.enqueueAction(a);  
    },
    
    updateSound: function (component, event) {
        var action = component.get("c.updateSoundField");
        action.setParams({
            taskwarpList: component.get("v.data")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                debugger;
                
            } else {
                debugger;
            }
        });
        $A.enqueueAction(action)
        
    }
})