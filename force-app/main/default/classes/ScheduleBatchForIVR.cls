global class ScheduleBatchForIVR  implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext sc) {
        IVRCalling.notifyLearnerForInterview();    
    }
}