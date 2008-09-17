package ch.capi.net
{
	/**
	 * Dispatched when the <code>IMassLoader</code> starts the loading of a file. This event
	 * is dispatched just before the <code>ILoadManager.start()</code> method is called.
	 * 
	 * @eventType	ch.capi.events.MassLoadEvent.FILE_OPEN
	 */
	[Event(name="fileOpen", type="ch.capi.events.MassLoadEvent")]
	
	/**
	 * Dispatched when the loading of a <code>ILoadManager</code> is closed (eg when the loading is complete or
	 * an error has occured).
	 * 
	 * @eventType	ch.capi.events.MassLoadEvent.FILE_CLOSE
	 */
	[Event(name="fileClose", type="ch.capi.events.MassLoadEvent")]
	
	/**
	 * Represents a massive loader. This interface represents objects that manages the
	 * loading of many files.
	 * 
	 * @see			ch.capi.net.LoadableFileFactory	LoadableFileFactory
	 * @see			ch.capi.net.CompositeMassLoader	CompositeMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.1
	 */
	public interface IMassLoader extends ILoadManager
	{
		/**
		 * Defines the <code>ILoadPolicy</code> to use.
		 */
		function get loadPolicy():ILoadPolicy;
		function set loadPolicy(value:ILoadPolicy):void;

		/**
		 * Defines the number of files that will be loaded simultaneously. If the value is changed
		 * during a load process, this won't affect it.
		 */
		function get parallelFiles():uint;
		function set parallelFiles(value:uint):void;
		
		/**
		 * Defines the <code>ILoadInfo</code> object linked to the <code>IMassLoader</code>.
		 */
		function get loadInfo():ILoadInfo;

		/**
		 * Defines the number of files being currently loaded. This value does not take care if the
		 * <code>Event.OPEN</code> event of each file has been launched. It is based on the
		 * <code>MassLoadEvent.FILE_OPEN</code> event.
		 * 
		 * @see	#numFilesOpen	numFilesOpen
		 */
		function get numFilesLoading():uint;
		
		/**
		 * Defines the number of files being currently open. This value is based on the files that
		 * have sent the <code>Event.OPEN</code> event.
		 * 
		 * @see	#numFilesLoading	numFilesLoading
		 */
		function get numFilesOpen():uint;

		/**
		 * Add a file to the loading queue.
		 * 
		 * @param	file		The file to add.
		 * @see		ch.capi.net.ILoadableFile		ILoadableFile
		 * @see		ch.capi.net.LoadableFileFactory	LoadableFileFactory
		 */
		function addFile(file:ILoadManager):void;
		
		/**
		 * Removes a file from the loading queue.
		 * 
		 * @param	file		The file to remove.
		 */
		function removeFile(file:ILoadManager):void;
		
		/**
		 * Get the files that will be loaded.
		 * 
		 * @return	An <code>Array</code> containing the files to load.
		 */
		function getFiles():Array;
		
		/**
		 * Get the number of files to be loaded.
		 * 
		 * @return	The number of file to load.
		 */
		function getFileCount():uint;
		
		/**
		 * Empty the loading queue.
		 */
		function clear():void;
	}
}
