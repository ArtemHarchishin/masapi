package ch.capi.net {	import ch.capi.events.IGlobalEventDispatcher;		import ch.capi.net.ILoadableFile;		/**	 * Dispatched after all the files have been downloaded	 * 	 * @see			ch.capi.net.MassLoader		MassLoader	 * @eventType	flash.events.Event.COMPLETE	 */	[Event(name="complete", type="flash.events.Event")]		/**	 * Dispatched when the download operation commences following a call to the <code>MassLoader.start()</code>	 * method.	 * 	 * @see			ch.capi.net.IMassLoader		IMassLoader	 * @eventType	flash.events.Event.OPEN	 */	[Event(name="open", type="flash.events.Event")]		/**	 * Dispatched when the <code>MassLoader</code> starts the loading of a file. This event	 * is dispatched just before the <code>ILoadManager.start()</code> method is called.	 * 	 * @see			ch.capi.net.MassLoader		MassLoader	 * @eventType	ch.capi.events.MassLoadEvent.FILE_OPEN	 */	[Event(name="fileOpen", type="ch.capi.events.MassLoadEvent")]		/**	 * Dispatched when the loading of a <code>ILoadManager</code> is closed (eg when the loading is complete or	 * an error has occured).	 * 	 * @see			ch.capi.net.MassLoader		MassLoader	 * @eventType	ch.capi.events.MassLoadEvent.FILE_CLOSE	 */	[Event(name="fileClose", type="ch.capi.events.MassLoadEvent")]		/**	 * Dispatched when the loading of a <code>ILoadManager</code> progresses.	 * 	 * @eventType	ch.capi.events.MassLoadEvent.FILE_PROGRESS	 */	[Event(name="fileProgress", type="ch.capi.events.MassLoadEvent")]		/**	 * Dispatched when the download operation stops. This is following a call to the <code>MassLoader.stop()</code>	 * method.	 * 	 * @see			ch.capi.net.MassLoader		MassLoader	 * @eventType	flash.events.Event.CLOSE	 */	[Event(name="close", type="flash.events.Event")]		/**	 * Dispatched when data is received as the download operation progresses. The <code>bytesTotal</code> and <code>bytesLoaded</code>	 * value are based on the overall progressing of the files stored in the loading queue. If the <code>bytesTotal</code> of a	 * <code>ILoadableFile</code> has not been retrieved, then the <code>virtualBytesTotal</code> value will be used.	 * 	 * @see			ch.capi.net.MassLoader		MassLoader	 * @eventType	flash.events.ProgressEvent.PROGRESS	 */	[Event(name="progress", type="flash.events.ProgressEvent")]		/**	 * Dispatched when the loading of files with a lower priority starts.	 * 	 * @see			ch.capi.net.PriorityMassLoader	PriorityMassLoader	 * @eventType	ch.capi.events.PriorityEvent.PRIORITY_CHANGED	 */	[Event(name="priorityChanged", type="ch.capi.events.PriorityEvent")]		/**	 * Represents a <code>IMassLoader</code> encapsulator to avoid too much code.	 *	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public interface ICompositeMassLoader extends IGlobalEventDispatcher	{		/**		 * Defines the name of the <code>ICompositeMassLoader</code>. If the name is		 * <code>null</code>, then the <code>ICompositeMassLoader</code> is not registered		 * in the global map.		 * 		 * @see	#get()		CompositeMassLoader.get()		 */		function get name():String;				/**		 * Defines the <code>IMassLoader</code> used.		 */		function get massLoader():IMassLoader;		/**		 * Creates a <code>ILoadableFile</code> from a url.		 * 		 * @param 	fileOrURL	The url of the file or an <code>Object</code> containing at least the 'url' attribute.		 * @param	fileType	The type of the file. If not defined and the fileOrURL parameter is an <code>Object</code>, then		 * 						the type will be extracted from the attribute 'type'.		 * @param	onOpen		The <code>Event.OPEN</code> listener.		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.		 * @param	onClose		The <code>Event.CLOSE</code> listener.		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.		 * @return	The created <code>ILoadableFile</code>.		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()		 * @see	ch.capi.net.ILoadableFile#properties			ILoadableFile.properties		 * @throws	ArgumentError	if the fileOrURL parameter is not defined.		 */		function createFile(fileOrURL:Object, 							fileType:String = null,							onOpen:Function=null, 				   			onProgress:Function=null, 				   			onComplete:Function=null, 				   			onClose:Function=null,				   			onIOError:Function=null,				   			onSecurityError:Function=null):ILoadableFile;				/**		 * Creates a <code>ILoadableFile</code> from a url and add it to the current loading queue. If the fileOrURL parameter is an object, 		 * all the properties will be put in the <code>ILoadableFile.properties</code> attribute of the created <code>ILoadableFile</code>.		 * 		 * @param 	fileOrURL	The url of the file or an <code>Object</code> containing at least the 'url' attribute.		 * @param	priority	The priority of the file (must be an int). If not defined and the fileOrURL parameter is an <code>Object</code>, then		 * 						the priority of the file will be extracted from the attribute 'priority'. If no priority is specified, then the		 * 						priority will be 0.		 * @param	fileType	The type of the file. If not defined and the fileOrURL parameter is an <code>Object</code>, then		 * 						the type will be extracted from the attribute 'type'.		 * @param	onOpen		The <code>Event.OPEN</code> listener.		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.		 * @param	onClose		The <code>Event.CLOSE</code> listener.		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.		 * @return	The created <code>ILoadableFile</code>.		 * @throws	ArgumentError			If <code>fileOrURl</code> is <code>null</code>.		 * @throws	ArgumentError			If the priority is invalid.		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()		 * @see	ch.capi.net.ILoadableFile#properties			ILoadableFile.properties		 * @see	ch.capi.net.PriorityMassLoader	PriorityMassLoader		 */		function addFile(   fileOrURL:Object, 							fileType:String = null,							priority:*=null,							onOpen:Function=null, 				   			onProgress:Function=null, 				   			onComplete:Function=null, 				   			onClose:Function=null,				   			onIOError:Function=null,				   			onSecurityError:Function=null):ILoadableFile;				/**		 * Retrieves all the files created by the <code>ICompositeMassLoader</code>. Note that the <code>ICompositeMassLoader</code>		 * register the files only if the <code>keepFiles</code> property is set to <code>true</code>.		 * 		 * @return	The created <code>ILoadableFile</code>.		 */		function getFiles():Array;				/**		 * Retrieves the <code>ILoadableFile</code> at the specified index.		 * 		 * @param	index	The index.		 * @return	The <code>ILoadableFile</code>.		 */		function getFileAt(index:uint):ILoadableFile;				/**		 * Retrieves the first file that matches the specified properties.		 * 		 * @param	props		An <code>Object</code> containing the properties to match.		 * @param	strict		Defines if the check must be strict or not.		 * @return	The first <code>ILoadableFile</code> instance that matches the properties		 * 			or <code>null</code>.		 * 					 * @see		ch.capi.net.ILoadableFile#properties	ILoadableFile.properties		 * @see		ch.capi.data.IMap#matches()				IMap.matches()		 */		function getFileByProps(props:Object, strict:Boolean=false):ILoadableFile;				/**		 * Retrieves all the files that matche the specified properties.		 * 		 * @param	props		An <code>Object</code> containing the properties to match.		 * @param	strict		Defines if the check must be strict or not.		 * @return	An <code>Array</code> of <code>ILoadableFile</code> that match the 		 * 			specified properties.		 * 					 * @see		ch.capi.net.ILoadableFile#properties	ILoadableFile.properties		 * @see		ch.capi.data.IMap#matches()				IMap.matches()		 */		function getFilesByProps(props:Object, strict:Boolean=false):Array;				/**		 * Retrieves the number of <code>ILoadableFile</code> instances that have been stored.		 * 		 * @return	The number of stored <code>ILoadableFile</code>.		 */		function getFileCount():uint;		/**		 * Starts the loading of the massive loader.		 * 		 * @param	noCache		If <code>true</code>, then all the files contained in this		 * 		<code>ICompositeMassLoader</code> will be added back in the <code>IMassLoader</code>		 * 		to be reloaded. This cache has <strong>nothing</strong> to do with the <code>useCache</code>		 * 		property of a <code>ILoadableFile</code>.		 * 				 * @see	ch.capi.net.ILoadManager#start	ILoadManager.start()		 * @see	ch.capi.net.ILoadableFile#useCache	ILoadableFile.useCache		 */		function start(noCache:Boolean=false):void;				/**		 * Stops the loading of the massive loader.		 * 		 * @see	ch.capi.net.ILoadManager#stop	ILoadManager.stop()		 */		function stop():void;				/**		 * Clears the loading queue of the <code>IMassLoader</code> and empty the references to the		 * created <code>ILoadableFile</code> instances.		 * 		 * @param	destroyAll	Defines if the <code>CompositeMassLoader</code> must destroy all the		 * 						files before clearing them.		 * @see	ch.capi.net.IMassLoader#clear	IMassLoader.clear()		 */		function clear(destroyAll:Boolean=true):void;	}}