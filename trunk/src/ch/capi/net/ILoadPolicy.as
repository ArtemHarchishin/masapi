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
		 * Defines if the massive loading can continue or not. This property will only
		 * be checked after the <code>processFileClose()</code> method has been called and
		 * only if it returns <code>null</code>.
		 */
		function get canContinue():Boolean;
		
		/**
		 * Called by a <code>IMassLoader</code> when a file download is complete. This can be due
		 * to a successful download or not (see the <code>closeEvent</code> parameters).
		 * 
		 * @param	file			The <code>ILoadManager</code> to process.
		 * @param	closeEvent 		The event within the <code>ILoadManager</code> is finished.
		 * @param	source			The <code>IMassLoader</code> processing the <code>ILoadManager</code>.
		 * @return	The <code>ILoadManager</code> to reload or <code>null</code> if there is nothing do.
		 */
		function processFileClose(file:ILoadManager, closeEvent:Event, source:IMassLoader):ILoadManager;
		
		/**
		 * Called by a <code>IMassLoader</code> before it starts to load the specified <code>ILoadManager</code>. If
		 * this method returns <code>null</code>, then the <code>IMassLoader</code> will simply skip the file.
		 * 
		 * @param	file		The <code>ILoadManager</code> before being started.
		 * @param	source			The <code>IMassLoader</code> processing the <code>ILoadManager</code>.
		 * @return	The <code>ILoadManager</code> to load or <code>null</code> if the <code>IMassLoader</code> must skip
		 * 			The file.
		 */
		function processFileOpen(file:ILoadManager, source:IMassLoader):ILoadManager;
	}
}