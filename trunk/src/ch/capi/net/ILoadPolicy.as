package ch.capi.net
{
	import flash.events.Event;	
	
	/**
	 * Represents a loading policy. The target of the objects implementing this
	 * interface is to decides for example whetever a file should be reloaded by
	 * the MassLoader or not.
	 * 
	 * @see			ch.capi.net.MassLoader	MassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface ILoadPolicy
	{
		/**
		 * Defines if the massive loading can continue or not.
		 */
		function get canContinue():Boolean;
		
		/**
		 * Called by the <code>MassLoader</code> when a file download is complete. This can be due
		 * to a successful download or not (see the <code>closeEvent</code> parameters).
		 * 
		 * @param	file			The <code>ILoadManager</code> to process.
		 * @param	closeEvent 		The event within the <code>ILoadManager</code> is finished.
		 * @return	The <code>ILoadManager</code> to reload or <code>null</code> if there is nothing do.
		 */
		function processFile(file:ILoadManager, closeEvent:Event):ILoadManager;
	}
}