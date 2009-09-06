package ch.capi.utils.logging 
{
	/**
	 * A LogHandler processing the logging information (send it into a file,
	 * append it to a TextField, ...)
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 * @see			ch.capi.utils.logging.Logger	Logger
	 */
	public interface ILogHandler 
	{
		/**
		 * Process the log information.
		 * 
		 * @param	level		The logging level.
		 * @param	text		The text to log.
		 * @param	methodPath	The method complete name.		
		 */
		function log(level:int, text:String, methodPath:String=null):void;
	}
}
