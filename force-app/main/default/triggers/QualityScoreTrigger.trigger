trigger QualityScoreTrigger on Quality_Score__c (after insert) {
    if(trigger.isafter && trigger.isInsert){
        system.debug('Before Insert');
        //QualityScoreTriggerHelper.updateQualityScore(trigger.new); UpdatedQualityScoreWithNewParams
        QualityScoreTriggerHelper.UpdatedQualityScoreWithNewParams(trigger.new);
    }
}