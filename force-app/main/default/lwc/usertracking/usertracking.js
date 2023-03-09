import { LightningElement } from 'lwc';
import uId from '@salesforce/user/Id';
import user_checkin from '@salesforce/apex/UserTracking.UserCheckin';
import user_checkout from '@salesforce/apex/UserTracking.UserCheckout';
import checkin_check from '@salesforce/apex/UserTracking.OnpageLoad';
import Break_time from '@salesforce/apex/UserTracking.BreakTime';
import Meeting_started_Ended from '@salesforce/apex/UserTracking.MeetingStarted';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Usertracking extends LightningElement {
    userId = uId;
   showCheckoutPopup = false;

    disable_checkin = false;
    disable_checkout = false;
    //disable_Breaktime = false;
    //disable_MeetingStart = false;
    //disable_MeetingEnd = false;
    areDetailsVisible = false;
    BreakTimeButtonLabel = 'Start Break Time';
    MeetingButtonlabel = 'Start Meeting';
    AO_Details;
    constructor () {
        debugger;
        super();
        //this.checkin_check();
    }
    connectedCallback() {
        this.checkin_check();
    }
     checkoutPopupHandler(){
        this.showCheckoutPopup = true;
    }

    dismissCheckoutPopupHanlder(){
        this.showCheckoutPopup = false;
    }
    checkin_check() {
        debugger;
        checkin_check({ userId: uId }).then(result => {
            this.disable_checkin = result.checkin;
            this.disable_checkout = result.checkout;
            //this.AO_Details = result.LoggedInAuditOfficer;
            if (result.checkin == true && result.LoggedInAuditOfficer.IsActive__c != undefined && result.LoggedInAuditOfficer.IsActive__c == true) {
                this.areDetailsVisible = true;
            }
            if(result.checkout){
                this.areDetailsVisible = false;
            }
            if (result.AOAvailableStatus == 'On Break') {
                this.BreakTimeButtonLabel = 'End Break Time';
            }
        }).catch(err => {
            console.log('err::' + err);
        })
    }

    checkin(event) {
        this.disable_checkin = true;
        debugger;
        console.log('uId::' + uId);
        // alert('userid::'+uId);
        user_checkin({ userId: uId }).then(result => {
            debugger;
            this.disable_checkout = false;
            
            //alert('result::'+result);
            if (result.eventStatus == 'Checkin successful' ) {
                this.disable_checkin = true;
                this.showSuccessToast(result);
                if (result.AuditOfficerDetails.IsActive__c == true) {
                    this.areDetailsVisible = true;
                }
            }
            if (result.eventStatus == 'You can not checkin on sunday.') {
                this.disable_checkin = true;
                this.showWarningToast(result);
            }
            if (result.eventStatus == 'Your checkin was already created.') {
                this.disable_checkin = true;
                this.showInfoToast(result);
            }
            if (result.eventStatus == 'User is not registered in system.Please contact to your admin.') {
                this.showWarningToast(result);
            }
            if (result.eventStatus == 'You can not checkin before 9:00 AM.') {
                this.showWarningToast(result);
            }


        }).catch(err => {
            console.log('Error:::' + err);
        })
    }

    checkout() {
        debugger;
        console.log('uId::' + uId);
        user_checkout({ userId: uId }).then(result => {
            //alert('result::'+result);
            this.disable_checkout = true;
                    
            this.areDetailsVisible = false;
            this.showSuccessToastCheckout(result);
            this.dismissCheckoutPopupHanlder();
            refreshApex(this.wiredResult);
            
        }).catch(err => {
            console.log('err::' + err);
        })
        alert('result::' + result);
        alert('userid::' + uId);
    }

    BreakTime(event) {
        debugger;
        var ButtonlabelForJS = event.target.label
        if (ButtonlabelForJS == 'Start Break Time') {
            Break_time({ userId: uId, buttonlabel : ButtonlabelForJS }).then(result => {
                //this.disable_Breaktime = true;
                if (result == 'Please fill out Interview Feedback before marking yourself on Break!!!') {
                    this.showInfoToast(result);
                }else{
                    this.showInfoToast(result);
                    this.BreakTimeButtonLabel = 'End Break Time';
                }
                
            }).catch(err => {
                console.log('err::' + err);
            })
        }
        else if (ButtonlabelForJS == 'End Break Time') {
            Break_time({ userId: uId, buttonlabel : ButtonlabelForJS }).then(result => {
                //this.disable_Breaktime = true;
                this.showInfoToast(result);
                this.BreakTimeButtonLabel = 'Start Break Time';
            }).catch(err => {
                console.log('err::' + err);
            })
        }  
    }
    MeetingStartEnd(event) {
        var MeetingButtonlabelForJS = event.target.label
        debugger;
        if (MeetingButtonlabelForJS == 'Start Meeting') {
            Meeting_started_Ended({ userId: uId, buttonlabel : MeetingButtonlabelForJS}).then(result => {
                if(result == 'Break Time Started'){
                    this.MeetingButtonlabel = 'End Meeting';
                }
                this.showInfoToast(result);
            }).catch(err => {
                console.log('err::' + err);
            })
        }
        else if (MeetingButtonlabelForJS == 'End Meeting') {
            Meeting_started_Ended({ userId: uId, buttonlabel : MeetingButtonlabelForJS}).then(result => {
                this.MeetingButtonlabel = 'Start Meeting';
                this.showInfoToast(result);
            }).catch(err => {
                console.log('err::' + err);
            })
        }
        
    }

    showSuccessToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Checkin',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        //eval("$A.get('e.force:refreshView').fire();");
    }

    showSuccessToastCheckout(msg) {
        const evt = new ShowToastEvent({
            title: 'Checkout',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showInfoToast(msg) {
        if (msg == 'Break Time Started') {
            const evt = new ShowToastEvent({
                title: 'Break Time!!',
                message: msg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else if (msg == 'Break Time Ended') {
            const evt = new ShowToastEvent({
                title: 'Meeting Started!!',
                message: msg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else if (msg == 'Meeting is Started') {
            const evt = new ShowToastEvent({
                title: 'Meeting Started!!',
                message: msg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else if (msg == 'Meeting is Ended') {
            const evt = new ShowToastEvent({
                title: 'Meeting Ended!!',
                message: msg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Checkin',
                message: msg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }

    showWarningToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Checkin',
            message: msg,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}