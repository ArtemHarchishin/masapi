package ch.capi.net 
{
	import flash.events.ProgressEvent;	
	import flash.events.Event;	
	import flash.net.URLRequest;		
	
	import ch.capi.events.GlobalEventDispatcher;	
	import ch.capi.events.PriorityEvent;	
	import ch.capi.events.MassLoadEvent;
	import ch.capi.data.ArrayList;	
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.IMassLoader;
	import ch.capi.net.ILoadableFile;
	import ch.capi.errors.NameAlreadyExistsError;	
	import ch.capi.data.DictionnaryMap;	
	import ch.capi.data.IMap;
	
	/**
	 * Dispatched after all the files have been downloaded
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Dispatched when the download operation commences following a call to the <code>MassLoader.start()</code>
	 * method.
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")]
	
	/**
	 * Dispatched when the <code>MassLoader</code> starts the loading of a file. This event
	 * is dispatched just before the <code>ILoadManager.start()</code> method is called.
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	ch.capi.events.MassLoadEvent.FILE_OPEN
	 */
	[Event(name="fileOpen", type="ch.capi.events.MassLoadEvent")]
	
	/**
	 * Dispatched when the loading of a <code>ILoadManager</code> is closed (eg when the loading is complete or
	 * an error has occured).
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	ch.capi.events.MassLoadEvent.FILE_CLOSE
	 */
	[Event(name="fileClose", type="ch.capi.events.MassLoadEvent")]
	
	/**
	 * Dispatched when the loading of a <code>ILoadManager</code> progresses.
	 * 
	 * @eventType	ch.capi.events.MassLoadEvent.FILE_PROGRESS
	 */
	[Event(name="fileProgress", type="ch.capi.events.MassLoadEvent")]
	
	/**
	 * Dispatched when the download operation stops. This is following a call to the <code>MassLoader.stop()</code>
	 * method.
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	flash.events.Event.CLOSE
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Dispatched when data is received as the download operation progresses. The <code>bytesTotal</code> and <code>bytesLoaded</code>
	 * value are based on the overall progressing of the files stored into the loading queue. If the <code>bytesTotal</code> of a
	 * <code>ILoadableFile</code> has not been retrieved, then the <code>virtualBytesTotal</code> value will be used.
	 * 
	 * @see			ch.capi.net.MassLoader		MassLoader
	 * @eventType	flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * Dispatched when the loading of files with a lower priority starts.
	 * 
	 * @see			ch.capi.net.PriorityMassLoader	PriorityMassLoader
	 * @eventType	ch.capi.events.PriorityEvent.PRIORITY_CHANGED
	 */
	[Event(name="priorityChanged", type="ch.capi.events.PriorityEvent")]
	
	/**
	 * This is a utility class to avoid too much verbose code within the Masapi API. Note that this
	 * class simply uses the <code>PriorityMassLoader</code> and <code>LoadableFileFactory</code> to creates
	 * the <code>ILoadableFile</code> and for the loading management.
	 * It is an encapsulation class to the core Masapi API core functions.
	 *
	 * <p>The <code>CompositeMassLoader</code> keeps by default a reference to the created <code>ILoadableFile</code>
	 * (see the <code>keepFiles</code> property).</p>
	 *
	 * @example
	 * The <code>CompositeMassLoader</code> keep a reference to the created files by default :
	 * <listing version="3.0">
	 * var cm:CompositeMassLoader = new CompositeMassLoader();
	 * cm.addFile("myAnimation.swf");
	 * cm.addFile("otherSWF.swf", LoadableFileType.BINARY);
	 * cm.addFile({url:"otherSWF.swf", type:LoadableFileType.BINARY, priority:30});
	 * cm.addFile("myVariables.txt", LoadableFileType.TEXT, 10);
	 * 
	 * cm.start();
	 * </listing>
	 *
	 * @example
	 * The <code>CompositeMassLoader</code> doesn't keep a reference to the created files :
	 * 
	 * <listing version="3.0">
	 * var cm:CompositeMassLoader = new CompositeMassLoader(false);
	 * var file1:ILoadableFile = cm.addFile("myAnimation.swf");
	 * var file2:ILoadableFile = cm.addFile("otherSWF.swf", LoadableFileType.BINARY);
	 * var file3:ILoadableFile = cm.addFile(new URLRequest("anotherFile.txt"));
	 * 
	 * cm.start();
	 * </listing>
	 *
	 * @see			ch.capi.net.LoadableFileFactory 	LoadableFileFactory
	 * @see			ch.capi.net.IMassLoader				IMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class CompositeMassLoader extends GlobalEventDispatcher
	{
		//---------//
		//Variables//
		//---------//
		private static var __storedLoaders:IMap 		= new DictionnaryMap(false);

		private var _storage:ArrayList 					= new ArrayList();
		private var _massLoader:PriorityMassLoader		= new PriorityMassLoader();
		private var _factory:LoadableFileFactory		= new LoadableFileFactory();
		private var _keepFiles:Boolean					= true;
		private var _name:String;

		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the name of the <code>CompositeMassLoader</code>. If the name is
		 * <code>null</code>, then the <code>CompositeMassLoader</code> is not registered
		 * into the global map.
		 * 
		 * @see	#get()		CompositeMassLoader.get()
		 */
		public function get name():String { return _name; }
		
		/**
		 * Defines if the <code>CompositeMassLoader</code> must keep references on the created
		 * <code>ILoadableFile</code> instances. If this is set to <code>false</code>, a reference must
		 * be kept on the <code>ILoadableFile</code> to prevent the Garbage Collector to delete them.
		 * 
		 * @see		#storeFile	storeFile()
		 */
		public function get keepFiles():Boolean { return _keepFiles; }
		
		/**
		 * Defines the <code>LoadableFileFactory</code> to use.
		 */
		public function get loadableFileFactory():LoadableFileFactory { return _factory; }
		public function set loadableFileFactory(value:LoadableFileFactory):void
		{ 
			if (value == null) throw new ArgumentError("value is not defined");
			_factory = value;
		}
		
		/**
		 * Defines the <code>PriorityMassLoader</code> to use.
		 */
		public function get massLoader():PriorityMassLoader { return _massLoader; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>CompositeMassLoader</code> object.
		 * 
		 * @param	name					The name of the <code>CompositeMassLoader</code>. That name must be unique. If no name is defined, then
		 * 									the instance won't be registered.
		 * @param	parallelFiles			The number of files to load at the same time.
		 */
		public function CompositeMassLoader(name:String=null, parallelFiles:int=0)
		{
			_name = name;
			_massLoader.parallelFiles = parallelFiles;
			
			registerTo(massLoader);
			registerLoader(name);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the <code>CompositeMassLoader</code> matching the specified name.
		 * 
		 * @param	name	The name of the <code>CompositeMassLoader</code>.
		 * @return	The <code>CompositeMassLoader</code>.
		 * @throws	Error	If there is no <code>CompositeMassLoader</code> matching the specified name.
		 */
		public static function get(name:String):CompositeMassLoader
		{
			var cml:CompositeMassLoader = __storedLoaders.getValue(name);
			if (cml == null) throw new Error("There is no CompositeMassLoader matching the name '"+name+"'");
			return cml;
		}

		/**
		 * Creates a <code>ILoadableFile</code> from a url. This method doesn't register the file to the <code>IMassLoader</code> but
		 * it stores it into the <code>CompositeMassLoader</code>. If the fileOrURL parameter is an object, all the properties will
		 * be put into the <code>ILoadableFile.properties</code> attribute of the created <code>ILoadableFile</code>.
		 * 
		 * @param 	fileOrURL	The url of the file or an <code>Object</code> containing at least the 'url' attribute.
		 * @param	fileType	The type of the file. If not defined and the fileOrURL parameter is an <code>Object</code>, then
		 * 						the type will be extracted from the attribute 'type'.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code>.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 * @see	ch.capi.net.ILoadableFile#properties			ILoadableFile.properties
		 * @throws	ArgumentError	if the fileOrURL parameter is not defined.
		 * 
		 * @example
		 * <listing version="3.0">
		 * var cm:CompositeMassLoader = new CompositeMassLoader(false);
		 * 
		 * //those three lines have the same behavior
		 * cm.createFile("myAnimation.swf", LoadableFileType.BINARY);
		 * cm.createFile({url:"myAnimation.swf", type:LoadableFileType.BINARY});
		 * cm.createFile(new URLRequest("myAnimation.swf"), LoadableFileType.BINARY);
		 * </listing>
		 */
		public function createFile( fileOrURL:Object, 
									fileType:String = null,
									onOpen:Function=null, 
						   			onProgress:Function=null, 
						   			onComplete:Function=null, 
						   			onClose:Function=null,
						   			onIOError:Function=null,
						   			onSecurityError:Function=null):ILoadableFile
		{
			//null url is not allowed
			if (fileOrURL == null) throw new ArgumentError("The fileOrURL is not defined");
			
			//retrieves the url
			var isObject:Boolean = (fileOrURL is String || fileOrURL is URLRequest);
			var url:* = (isObject) ? fileOrURL : fileOrURL.url;
			var request:URLRequest = LoadableFileFactory.getRequest(url);
			
			//retrieves the type
			if (fileType == null && !isObject) fileType = fileOrURL.type;
			
			//initialize the loadable file
			var file:ILoadableFile = createLoadableFile(request, fileType);
			_factory.attachListeners(file,onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			
			//store the file if needed
			if (keepFiles) storeFile(file);
			
			//put the properties
			if (!isObject) file.properties.variables.putObject(fileOrURL);
			
			return file;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> from a url and add it to the current loading queue. If the fileOrURL parameter is an object, 
		 * all the properties will be put into the <code>ILoadableFile.properties</code> attribute of the created <code>ILoadableFile</code>.
		 * 
		 * @param 	fileOrURL	The url of the file or an <code>Object</code> containing at least the 'url' attribute.
		 * @param	priority	The priority of the file (must be an int). If not defined and the fileOrURL parameter is an <code>Object</code>, then
		 * 						the priority of the file will be extracted from the attribute 'priority'. If no priority is specified, then the
		 * 						priority will be 0.
		 * @param	fileType	The type of the file. If not defined and the fileOrURL parameter is an <code>Object</code>, then
		 * 						the type will be extracted from the attribute 'type'.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code>.
		 * @throws	ArgumentError			If the priority is invalid.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 * @see	ch.capi.net.ILoadableFile#properties			ILoadableFile.properties
		 * @see	ch.capi.net.PriorityMassLoader	PriorityMassLoader
		 * 
		 * @example
		 * <listing version="3.0">
		 * var cm:CompositeMassLoader = new CompositeMassLoader(false);
		 * 
		 * //those three lines have the same behavior
		 * cm.addFile("myAnimation.swf", LoadableFileType.BINARY, 10);
		 * cm.addFile({url:"myAnimation.swf", type:LoadableFileType.BINARY, priority:10});
		 * cm.addFile(new URLRequest("myAnimation.swf"), LoadableFileType.BINARY, 10);
		 * </listing>
		 */
		public function addFile(fileOrURL:Object, 
								fileType:String = null,
								priority:*=null,
								onOpen:Function=null, 
					   			onProgress:Function=null, 
					   			onComplete:Function=null, 
					   			onClose:Function=null,
					   			onIOError:Function=null,
					   			onSecurityError:Function=null):ILoadableFile
		{
			//parse the priority
			if (priority != null && !(priority is int)) throw new ArgumentError("Illegal value for priority : "+priority);
			if (priority == null && !(fileOrURL is String  || file is URLRequest)) priority = fileOrURL.priority; 
			if (priority == null) priority = 0;
			if (!(priority is int)) throw new ArgumentError("Illegal value for priority : "+priority);
			
			//creates the file an put it into the loading queue
			var file:ILoadableFile = createFile(fileOrURL, fileType, onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			_massLoader.addPrioritizedFile(file, priority as int);
			
			return file;
		}
		
		/**
		 * Retrieves all the files created by the <code>CompositeMassLoader</code>. Note that the <code>CompositeMassLoader</code>
		 * register the files only if the <code>keepFiles</code> property is set to <code>true</code>.
		 * 
		 * @return	The created <code>ILoadableFile</code>.
		 */
		public function getFiles():Array
		{
			return _storage.toArray();
		}
		
		/**
		 * Retrieves the <code>ILoadableFile</code> at the specified index.
		 * 
		 * @param	index	The index.
		 * @return	The <code>ILoadableFile</code>.
		 */
		public function getFileAt(index:uint):ILoadableFile
		{
			return _storage.getElementAt(index) as ILoadableFile;
		}
		
		/**
		 * Retrieves the number of <code>ILoadableFile</code> instances that have been stored.
		 * 
		 * @return	The number of stored <code>ILoadableFile</code>.
		 */
		public function getFileCount():uint
		{
			return _storage.length;
		}

		/**
		 * Starts the loading of the massive loader.
		 * 
		 * @see	ch.capi.net.ILoadManager#start	ILoadManager.start()
		 */
		public function start():void
		{
			_massLoader.start();
		}
		
		/**
		 * Stops the loading of the massive loader.
		 * 
		 * @see	ch.capi.net.ILoadManager#stop	ILoadManager.stop()
		 */
		public function stop():void
		{
			_massLoader.stop();
		}
		
		/**
		 * Clears the loading queue of the <code>IMassLoader</code> and empty the references to the
		 * created <code>ILoadableFile</code> instances.
		 * 
		 * @see	ch.capi.net.IMassLoader#clear	IMassLoader.clear()
		 */
		public function clear():void
		{
			_massLoader.clear();
			_storage.clear();
		}
		
		//-------------------//
		//Protected functions//
		//-------------------//
		
		/**
		 * Retrieves a <code>ILoadableFile</code> from a <code>URLRequest</code> and and a specified file type
		 * issued from the <code>LoadableFileType</code> constants.
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @param	fileType	The type of the file.
		 * @return	The <code>ILoadableFile</code> created.
		 * @throws	ArgumentError	If the <code>fileType</code> is not valid.
		 * @see ch.capi.net.LoadableFileFactory#getRequest()	LoadableFileFactory.getRequest()
		 */
		protected function createLoadableFile(request:URLRequest, fileType:String=null):ILoadableFile
		{
			return _factory.createFile(request, fileType);
		}
		
		/**
		 * Stores the specified <code>ILoadableFile</code>.
		 * 
		 * @param file	The file to store.
		 */
		protected function storeFile(file:ILoadableFile):void
		{
			_storage.addElement(file);
		}
		
		/**
		 * Register as listener to the specified <code>IMassLoader</code>.
		 * 
		 * @param	massLoader		The <code>IMassLoader</code> to listen.
		 */
		protected function registerTo(massLoader:IMassLoader):void
		{
			massLoader.addEventListener(Event.OPEN, eventRedirector, false, 0, true);
			massLoader.addEventListener(Event.CLOSE, eventRedirector, false, 0, true);
			massLoader.addEventListener(ProgressEvent.PROGRESS, eventRedirector, false, 0, true);
			massLoader.addEventListener(Event.COMPLETE, eventRedirector, false, 0, true);
			massLoader.addEventListener(MassLoadEvent.FILE_OPEN, eventRedirector, false, 0, true);
			massLoader.addEventListener(MassLoadEvent.FILE_CLOSE, eventRedirector, false, 0, true);
			massLoader.addEventListener(MassLoadEvent.FILE_PROGRESS, eventRedirector, false, 0, true);
			massLoader.addEventListener(PriorityEvent.PRIORITY_CHANGED, eventRedirector, false, 0, true);
		}
		
		/**
		 * Unregister from the specified <code>IMassLoader</code>.
		 * 
		 * @param	massLoader	The <code>IMassLoader</code> to stop to listen to.
		 */
		protected function unregisterFrom(massLoader:IMassLoader):void
		{
			massLoader.removeEventListener(Event.OPEN, eventRedirector);
			massLoader.removeEventListener(Event.CLOSE, eventRedirector);
			massLoader.removeEventListener(ProgressEvent.PROGRESS, eventRedirector);
			massLoader.removeEventListener(Event.COMPLETE, eventRedirector);
			massLoader.removeEventListener(MassLoadEvent.FILE_OPEN, eventRedirector);
			massLoader.removeEventListener(MassLoadEvent.FILE_CLOSE, eventRedirector);
			massLoader.removeEventListener(MassLoadEvent.FILE_PROGRESS, eventRedirector);
			massLoader.removeEventListener(PriorityEvent.PRIORITY_CHANGED, eventRedirector);
		}
		
		/**
		 * Redirects all the events that it received. This method acts like a proxy : it is attached
		 * to a <code>IMassLoader</code> as event listener and all the events are redispatched through
		 * the <code>CompositeMassLoader</code>. Note that all the events are cloned before redirection.
		 * 
		 * @param	evt		The <code>Event</code> object.
		 */
		protected function eventRedirector(evt:Event):void
		{
			var c:Event = evt.clone();
			dispatchEvent(c);
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 * Registers the <code>CompositeMassLoader</code> into the static map.
		 * 
		 * @param	name		The name. If the name is not specified, then this method does nothing.
		 * @throws	ch.capi.errors.NameAlreadyExistsError	If the name is not unique.
		 */
		private function registerLoader(name:String=null):void
		{
			if (name == null) return; //do nothing
			if (__storedLoaders.containsKey(name)) throw new NameAlreadyExistsError("The name '"+name+"' is already exists");
			
			__storedLoaders.put(name, this);	
		}
	}
}
