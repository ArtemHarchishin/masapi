package ch.capi.errors
{
	/**
	 * Error thrown when a dependey is not safe.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class DependencyNotSafeError extends Error
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>DependencyNotSafeError</code> object.
		 * 
		 * @param 	message		The error message.
		 */
		public function DependencyNotSafeError(message:String=null):void
		{
			super(message);
		}
	}
}