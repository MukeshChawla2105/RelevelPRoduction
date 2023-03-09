global class ExotelApiCalloutSchedular
{
    global void ExotelApiCalloutSchedular() {}
    public static void start()
    {
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        //System.schedule('Stock Price Update', '0 0 1-23 * * ?', new CallExotelApi());
        System.schedule('Process Leads at Half Hours','0 0 * 30 * ?n',new CallExotelApi());
    }
}