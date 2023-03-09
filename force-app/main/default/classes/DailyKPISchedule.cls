global class DailyKPISchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        DailyKPIs.calculateDailyKPIs();
       //String cronexpression = '0 */2 * * *';
//System.schedule('Testing', cronexpression, DailyKPIs.calculateDailyKPIs());
    }
    
}