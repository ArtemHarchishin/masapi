package ch.capi.net
{
	import flash.events.Event;	
	import flash.events.IEventDispatcher;
	
	/**
	 * Dispatched after all the received data is received.
	 * 
	 * @eventType	flash.events.Event.COMPLETE 
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Dispatched when the download operation commences following a call to the <code>ILoadManager.load()</code>
	 * method.
	 * 
	 * @eventType	flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")]
	
	/**
	 * Dispatched when the download operation stops. This is following a call to the <code>ILoadManager.stop()</code>
	 * method.
	 * 
	 * @eventType	flash.events.Event.CLOSE
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Dispatched when data is received as the download operation progresses.
	 * 
	 * @eventType	flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * Represents a load manager. This manager should be able to manage all the events
	 * related to the loading of a file.
	 * 
	 * @see			ch.capi.net.CompositeMassLoader	CompositeMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.1
	 */
	public interface ILoadManager extends IEventDispatcher
	{
		/**
		 * Defines if the <code>ILoadManager</code> operation is complete. This
		 * value is <code>true</code> only if the data has been successfully loaded.
		 */
		function get loaded():Boolean;
		
		/**
		 * Defines if the <code>ILoadManager</code> is loading.
		 */
		function get stateLoading():Boolean;
		
		/**
		 * Defines if the <code>ILoadManager</code> is idle.
		 */
		function get stateIdle():Boolean;
		
		/**
		 * Defines the bytes that have been loaded.
		 */
		function get bytesLoaded():uint;
		
		/**
		 * Defines the total bytes to load.
		 */
		function get bytesTotal():uint;
		
		/**
		 * Defines the event that happend to close the file (Event.CLOSE, Event.COMPLETE, ...).
		 */
		function get closeEvent():Event;

		/**
		 * Stops the load operation in progress.
		 * Any load operation in progress is immediately terminated.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>ILoadManager</code> is not loading.
		 */
		function stop():void;
		
		/**
		 * Starts downloading data from the specified URL.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>ILoadManager</code> is already loading.
		 */
		function start():void;
	}
}