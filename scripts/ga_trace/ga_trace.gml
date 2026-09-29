/// @description print arguments to log
/// @param ... arguments to print
function ga_trace() {

	if (!variable_global_exists("ga_logfile"))
	{
		global.ga_logfile = "logs/ga_log.txt";
		var fileHandle = file_text_open_write(global.ga_logfile);
		file_text_close(fileHandle);
	}

	var logLine = "GameAnalytics: " + string(argument[0]), i;
	for (i = 1; i < argument_count; i++) 
	{
	    logLine += ", " + string(argument[i]);
	}

	var log_file = file_text_open_append(global.ga_logfile);
	file_text_write_string(log_file, logLine);
	file_text_writeln(log_file);
	file_text_close(log_file);
	show_message(logLine);


}
