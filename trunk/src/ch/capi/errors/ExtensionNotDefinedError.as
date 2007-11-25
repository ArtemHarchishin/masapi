package ch.capi.errors
{
	/**
	 * Error thrown when an extension is not defined.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class ExtensionNotDefinedError extends Error
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ExtensionNotDefinedError</code> object.
		 * 
		 * @param	ext		The extension.
		 */
		public function ExtensionNotDefinedError(ext:String=null):void
		{
			super("The extension '"+ext+"' is not defined");
		}
	}
}