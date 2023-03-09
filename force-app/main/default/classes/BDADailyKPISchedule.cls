global class BDADailyKPISchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        BDADailyKPI.bdsKPICalculation();
    }
}