package ch.capi.errors
{
	/**
	 * Error orrured during a parse operation.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class ParseError extends Error
	{
		//---------//
		//Variables//
		//---------//
		private var _source:*;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the source of the error.
		 */
		public function get source():Object { return _source; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ParseError</code> object.
		 * 
		 * @param	method			The part of the parsing where the error occured (essentially the method).
		 * @param	message			The error message.
		 * @param	source			The source of the error.
		 */
		public function ParseError(method:String=null, message:String=null, source:Object=null):void
		{
			super("["+method+"] "+message, 0);
			
			_source = source;
		}
	}
}