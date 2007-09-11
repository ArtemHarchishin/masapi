package ch.capi.errors
{
	/**
	 * Error thrown when a name that should be unique is duplicated.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class NameAlreadyExistsError extends Error
	{
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>NameAlreadyExistsError</code> object.
		 * 
		 * @param	name	The name that is duplicated.
		 */
		public function NameAlreadyExistsError(name:String=null):void
		{
			super("The name '"+name+"' already exists");
		}
	}
}