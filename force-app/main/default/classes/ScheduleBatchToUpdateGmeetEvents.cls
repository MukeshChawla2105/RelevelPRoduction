global class ScheduleBatchToUpdateGmeetEvents implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToUpdateGmeetTask b = new BatchToUpdateGmeetTask(); 
      Database.executeBatch(b, 1);
   }

}