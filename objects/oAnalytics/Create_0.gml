// Инициализация GameAnalytics 
if (instance_number(oAnalytics) > 1) { 
    instance_destroy()
    exit
}

analyticsInit()
