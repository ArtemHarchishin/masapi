package ch.capi.net
{
	import ch.capi.data.DictionnaryMap;	
	import ch.capi.data.IMap;	
	import ch.capi.data.IList;
	import ch.capi.data.IDataStructure;
	import ch.capi.data.QueueList;
	import ch.capi.data.ArrayList;
	import ch.capi.events.MassLoadEvent;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.errors.IllegalOperationError;
	import flash.utils.setTimeout;
	
	/**
	 * Dispatched after all the data is received.
	 * 
	 * @eventType	flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Dispatched when the download operation commences following a call to the <code>MassLoader.load()</code>
	 * method.
	 * 
	 * @eventType	flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")]
	
	/**
	 * Dispatched when the <code>MassLoader</code> starts the loading of a file. This event
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
	 * Dispatched when the download operation stops. This is following a call to the <code>MassLoader.stop()</code>
	 * method.
	 * 
	 * @eventType	flash.events.Event.CLOSE
	 */
	[Event(name="close", type="flash.events.Event")]
	
	/**
	 * Dispatched when data is received as the download operation progresses. The <code>bytesTotal</code> and <code>bytesLoaded</code>
	 * value are based on the overall progressing of the files stored into the loading queue. If the <code>bytesTotal</code> of a
	 * <code>ILoadableFile</code> has not been retrieved, then the <code>virtualBytesTotal</code> value will be used.
	 * 
	 * @eventType	flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * This is a basic implementation of a <code>IMassLoader</code> object. The files will be loaded
	 * into the order of they have been added into the loading queue. In order to create some <code>ILoadableFile</code>,
	 * use the <code>LoadableFileFactory</code> class. If you want to specify some priority
	 * to the loaded files, check the <code>PriorityMassLoader</code> class.
	 * <p>It is important to note that the files won't be stored anymore after they have been completely loaded. You should
	 * have anoter reference to the created <code>ILoadManager</code> objects to access them and prevent that the Garbage Collector
	 * destroy them.</p>
	 * 
	 * @example
	 * Basic usage (limited verbose code) :
	 * <listing version="3.0">
	 * var cl:CompositeMassLoader = new CompositeMassLoader();
	 * cl.addFile("myFile.txt");
	 * cl.addFile("myAnim.swf");
	 * 
	 * var ml:IMassLoader = cl.massLoader;
	 * var eventFile:Function = function(evt:MassLoadEvent):void
	 * {
	 *    var src:ILoadableFile = (evt.file as ILoadableFile);
	 *    trace(evt.type+" => "+src.urlRequest.url);
	 * }
	 * ml.addEventListener(MassLoadEvent.FILE_OPEN, eventFile);
	 * ml.addEventListener(MassLoadEvent.FILE_CLOSE, eventFile);
	 * 
	 * var onMassLoadComplete:Function = function(evt:Event):void
	 * {
	 *    trace("massload complete");
	 * }
	 * ml.addEventListener(Event.COMPLETE, onMassLoadComplete);
	 * 
	 * cl.start();
	 * //ml.start() also works
	 * </listing>
	 * 
	 * Advanced usage :
	 * <listing version="3.0">
	 * var lf:LoadableFileFactory = new LoadableFileFactory();
	 * var file1:ILoadableFile = lf.create("myFile.txt");
	 * var file2:ILoadableFile = lf.create("myAnim.swf");
	 * 
	 * var ml:MassLoader = new MassLoader();
	 * ml.addFile(file1);
	 * ml.addFile(file2);
	 * 
	 * var eventFile:Function = function(evt:MassLoadEvent):void
	 * {
	 *    var src:ILoadableFile = (evt.file as ILoadableFile);
	 *    trace(evt.type+" => "+src.urlRequest.url);
	 * }
	 * ml.addEventListener(MassLoadEvent.FILE_OPEN, eventFile);
	 * ml.addEventListener(MassLoadEvent.FILE_CLOSE, eventFile);
	 * 
	 * var onMassLoadComplete:Function = function(evt:Event):void
	 * {
	 *    trace("massload complete");
	 * }
	 * ml.addEventListener(Event.COMPLETE, onMassLoadComplete);
	 * 
	 * ml.start();
	 * </listing>
	 * 
	 * @see			ch.capi.net.ILoadPolicy			ILoadPolicy
	 * @see			ch.capi.net.LoadableFileFactory	LoadableFileFactory
	 * @see			ch.capi.net.CompositeMassLoader	CompositeMassLoader
	 * @see			ch.capi.net.PriorityMassLoader	PriorityMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.2
	 */
	public class MassLoader extends EventDispatcher implements IMassLoader
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Priority of the listener on a <code>ILoadableFile</code>.
		 * 
		 * @see		#registerTo()		registerTo()
		 */
		private static const LISTENER_PRIORITY:int = -100;
		
		//---------//
		//Variables//
		//---------//
		private var _filesQueue:IDataStructure			= new QueueList();
		private var _filesToLoad:IList					= new ArrayList();
		private var _filesLoading:IList					= new ArrayList();
		private var _filesIndex:IMap 					= new DictionnaryMap(true);
		private var _currentFileIndex:int				= 0;
		private var _isLoading:Boolean					= false;
		private var _closeEvent:Event					= null;
		private var _loadInfo:ILoadInfo;
		private var _useCache:Boolean;
		private var _parallelFiles:uint;
		private var _loadPolicy:ILoadPolicy;
		private var _currentFilesLoading:uint			= 0;
		private var _tempTotalBytes:uint				= 0; //used to manage the total bytes
		private var _realTotalBytes:uint 				= 0;
		private var _realLoadedBytes:uint				= 0;
		
		/**
		 * Defines if the progress event should be dispatched each time or
		 * only when all the number of specified parallel files are being
		 * loaded.
		 * <p>This value was set to <code>false</code> up to masapi 1.5.</p>
		 */
		public var alwaysDispatchProgressEvent:Boolean = true;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the bytes that have been loaded.
		 */
		public function get bytesLoaded():uint { return _realLoadedBytes; }
		
		/**
		 * Defines the total bytes to load.
		 */
		public function get bytesTotal():uint { return _realTotalBytes; }
		
		/**
		 * Defines the <code>ILoadInfo</code> object linked to the <code>IMassLoader</code>. You can
		 * just trace this value if you want to have some useful information.
		 * 
		 * @example
		 * <listing version="3.0">
		 * function onLoadProgress(evt:ProgressEvent):void
		 * {
		 * 		trace(evt.target.loadInfo);
		 * }
		 * 
		 * myMassLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
		 * </listing>
		 */
		public function get loadInfo():ILoadInfo { return _loadInfo; }

		/**
		 * Defines if the <code>MassLoader</code> can use the cache or not. Note that if this property
		 * is set to <code>false</code>, it will call the <code>ILoadManager.start()</code> method on 
		 * all the files. If <code>true</code>, it will test if the file is already loaded 
		 * (<code>bytesLoaded</code> == <code>bytesTotal</code>) and call the <code>ILoadManager.start()</code>
		 * if not.
		 */
		public function get useCache():Boolean { return _useCache; }
		public function set useCache(value:Boolean):void { _useCache = value; }
		
		/**
		 * Defines if the <code>MassLoader</code> is loading.
		 */
		public function get stateLoading():Boolean { return _isLoading; }
		
		/**
		 * Defines if the <code>MassLoader</code> is idle.
		 */
		public function get stateIdle():Boolean { return !_isLoading; }
		
		/**
		 * Defines the next file that will be extracted from the queue to be loaded.
		 */
		public function get nextFileToLoad():ILoadManager { return _filesQueue.nextElement; }
		
		/**
		 * Defines the <code>ILoadPolicy</code> to use. If the specified <code>ILoadPolicy</code> returns a 
		 * <code>ILoadManager</code>, then the loaded bytes of the current file are decremented from the 
		 * <code>bytesLoaded</code> and <code>bytesTotal</code> properties !
		 */
		public function get loadPolicy():ILoadPolicy { return _loadPolicy; }
		public function set loadPolicy(value:ILoadPolicy):void
		{
			if (value == null) throw new ArgumentError("value is not defined");
			_loadPolicy = value;
		}

		/**
		 * Defines the number of files that will be loaded simultaneously. If the value is changed
		 * during a load process, this won't affect it.
		 */
		public function get parallelFiles():uint { return _parallelFiles; }
		public function set parallelFiles(value:uint):void { _parallelFiles = value; }
		
		/**
		 * Defines the number of files being currently loaded. This value does not take care if the
		 * <code>Event.OPEN</code> event of each file has been launched. It is based on the
		 * <code>MassLoadEvent.FILE_OPEN</code> event.
		 * 
		 * @see	#numFilesOpen	numFilesOpen
		 */
		public function get numFilesLoading():uint { return _currentFilesLoading; }
		
		/**
		 * Defines the number of files being currently open. This value is based on the files that
		 * have sent the <code>Event.OPEN</code> event.
		 * 
		 * @see	#numFilesLoading	numFilesLoading
		 */
		public function get numFilesOpen():uint { return _filesLoading.length; }
		
		/**
		 * Defines the event that happend to close the <code>MassLoader</code> (Event.CLOSE or Event.COMPLETE). This
		 * value is <code>null</code> if the <code>MassLoader</code> has not be started or is currently loading files.
		 */
		public function get closeEvent():Event { return _closeEvent; }
		
		/**
		 * Defines the data structure to use for the file enqueuing. By default, a
		 * <code>QueueList</code> is used. The <code>MassLoader</code> will use this
		 * <code>IDataStructure</code> to retrieves the next file to load. All the objects
		 * contained into the list must implement the <code>ILoadManager</code> interface.
		 * 
		 * @see		#files						files
		 * @see		#filesLoading				filesLoading
		 * @see		ch.capi.net.ILoadManager	ILoadManager
		 */
		protected function get filesQueue():IDataStructure { return _filesQueue; }
		protected function set filesQueue(value:IDataStructure):void
		{
			if (value == null) throw new ArgumentError("value is not defined");
			_filesQueue = value;
		}
		
		/**
		 * Defines all the files that must be loaded.
		 * <p>Note that a file can be in the files list and not in the queue list. It means
		 * that the file is currently being loaded. After being loaded, the file is totally
		 * removed from the <code>MassLoader</code>.</p>
		 */
		protected function get files():IList { return _filesToLoad; }
		
		/**
		 * Defines the files that are currently being loaded. This list conaints only the files
		 * that dispatches the <code>Event.OPEN</code> event.
		 * 
		 * @see		#files		files
		 * @see		#filesQueue	filesQueue
		 * @see		#onOpen()	onOpen()
		 */
		protected function get filesLoading():IList { return _filesLoading; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>MassLoader</code> object.
		 * 
		 * @param	parallelFiles	The number of files to be loaded simultaneously.
		 * @param	useCache		Defines if the <code>MassLoader</code> must use the static cache or not.
		 * @param	loadPolicy		The <code>ILoadPolicy</code> to use.
		 */
		public function MassLoader(parallelFiles:uint=0, useCache:Boolean=true, loadPolicy:ILoadPolicy=null):void
		{
			_loadInfo = new MassLoadInfo(this);
			_parallelFiles = parallelFiles;
			_useCache = useCache;
			_loadPolicy = (loadPolicy==null) ? new DefaultLoadPolicy() : loadPolicy;
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add a file to the loading queue. A file added while the <code>MassLoader<code>
		 * is already running will not be added to the current loading queue. You should stop
		 * and restart the <code>MassLoader</code> in order to include the file into the loading.
		 * 
		 * @param	file		The file to add.
		 * @throws	flash.errors.IllegalOperationError	If the file is already into the loading queue.
		 * @see		#hasFile()						hasFile()
		 * @see		ch.capi.net.ILoadableFile		ILoadableFile
		 * @see		ch.capi.net.LoadableFileFactory	LoadableFileFactory
		 */
		public function addFile(file:ILoadManager):void
		{
			if (hasFile(file)) throw new IllegalOperationError("The file is already into the loading queue");
			
			_filesToLoad.addElement(file);
			_filesIndex.put(file, _currentFileIndex++);
		}

		/**
		 * Removes a file from the loading queue.
		 * 
		 * @param	file		The file to remove.
		 * @throws	flash.errors.IllegalOperationError	If the file is not into the loading queue.
		 * @see		#hasFile()						hasFile()
		 * @see		ch.capi.net.ILoadableFile		ILoadableFile
		 * @see		ch.capi.net.LoadableFileFactory	LoadableFileFactory
		 */
		public function removeFile(file:ILoadManager):void
		{
			if (!hasFile(file)) throw new IllegalOperationError("The file is not into the loading queue");
			
			_filesToLoad.removeElement(file);
			if (_filesToLoad.length == 0) _currentFileIndex = 0;
		}

		/**
		 * Retrieves if a file is contained into the loading queue.
		 * 
		 * @param	file	The <code>ILoadManager</code>.
		 * @return	<code>true</code> if the file is into the loading queue.
		 */
		public function hasFile(file:ILoadManager):Boolean
		{
			return _filesToLoad.getElementIndex(file) != -1;
		}
		
		/**
		 * Get the files that will be loaded.
		 * 
		 * @return	An <code>Array</code> containing the files to load.
		 */
		public function getFiles():Array
		{
			return _filesToLoad.toArray();
		}
		
		/**
		 * Get the number of files to be loaded.
		 * 
		 * @return	The number of file to load.
		 */
		public function getFileCount():uint
		{
			return _filesToLoad.length;
		}
		
		/**
		 * Stops the load operation in progress.
		 * Any load operation in progress is immediately terminated.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>MassLoader</code> is not loading.
		 */
		public final function stop():void
		{
			if (!_isLoading) throw new IllegalOperationError("State not loading");
			_isLoading = false;
			
			//stop all the files
			var l:uint = _filesLoading.length;
			for (var i:uint=0 ; i<l ; i++)
			{
				var f:ILoadManager = _filesLoading.getElementAt(i) as ILoadManager;
				stopLoadingFile(f);
			}
			
			//dispatch the close event
			var evt:Event = new Event(Event.CLOSE);
			_closeEvent = evt;
			dispatchEvent(evt);
		}
		
		/**
		 * Starts downloading data from the specified <code>ILoadableFile</code> objects.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>MassLoader</code> is already loading.
		 */
		public final function start():void
		{
			if (_isLoading) throw new IllegalOperationError("State already loading");
			_isLoading = true;
			_closeEvent = null;
			
			//init
			_tempTotalBytes = 0;
			_currentFilesLoading = 0;
			_filesLoading.clear(); //empty the files being loaded
			_filesQueue.clear(); //empty the files queue to load
			_loadInfo.reset(); //reset the load information
			
			//put all the files into the queue
			var l:uint = _filesToLoad.length;
			for (var i:uint=0 ; i<l ; i++) _filesQueue.add(_filesToLoad.getElementAt(i));
			
			//update the current loaded values
			updateBytes();
			
			//open event
			var evt:Event = new Event(Event.OPEN);
			dispatchEvent(evt);
			
			/*
			 * Checks the number of files.
			 * If there is no file to load, then wait some milliseconds before launch the complete
			 * event so the listeners can register to the MassLoader !
			 */
			if (_filesQueue.isEmpty()) setTimeout(doComplete, 20);
			else loadNext();
		}
		
		/**
		 * Empty the loading queue. This will not affect the current loading.
		 */
		public function clear():void
		{
			_filesToLoad.clear();
			_filesIndex.clear();
			_currentFileIndex = 0;
		}
		
		/**
		 * Lists all the files contained into this <code>MassLoader</code> into a <code>String</code>.
		 * 
		 * @return A <code>String</code> containing all the files.
		 */
		public override function toString():String
		{
			return "MassLoader["+_filesToLoad.toArray()+"]";
		}

		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Start the loading of the next file. If there is no more file to load,
		 * then a <code>null</code> value is returned. Before the next file is being loaded,
		 * it is removed from the loading queue.
		 * 
		 * @return	The <code>ILoadManager</code> object being loaded or <code>null</code>.
		 */
		protected function loadNextFile():ILoadManager
		{
			//no more file
			if (_filesQueue.isEmpty()) return null;
			
			//retrieve the next file
			var nextFile:ILoadManager = extractNextFile();
			
			//launch the loading of the file
			return (loadFile(nextFile) ? nextFile : null);
		}
		
		/**
		 * Start the loading of a file. The file specified will not be removed from the loading queue !
		 * 
		 * @param	file		The <code>ILoadManager</code> to load.
		 * @return	<code>true</code> if the loading has been started.
		 */
		protected final function loadFile(file:ILoadManager):Boolean
		{
			//register to the file
			_currentFilesLoading++;
			registerTo(file);
			
			//open event
			var index:int = getFileIndex(file);
			var op:MassLoadEvent = new MassLoadEvent(MassLoadEvent.FILE_OPEN, file, null, index);
			dispatchEvent(op);
			
			//try to start the loading
			try
			{
				/*
				Here we use a "static" cache. It only checks whenever the bytesLoaded
				and bytesTotal value are equal or not and if not, it simply add the file
				to the loading queue. This check is do only if the MassLoader useCache=true
				and the file.useCache=true.
				*/
				if (!useCache || !file.useCache || file.bytesTotal == 0 || file.bytesLoaded < file.bytesTotal)
				{
					file.start();
					return true;
				}
			}
			catch(e:Error)
			{
				//do nothing :)
			}
			
			//problem during the launching => stop it !
			closeFile(file, null);
			return false;
		}
		
		/**
		 * Start the loading of the files. This method will launch the loading of the files (using
		 * the <code>loadNextFile()</code> method). The number of loading launched is determined by
		 * the <code>parallelFiles</code> value.
		 * 
		 * @see		#parallelFiles		parallelFiles
		 */
		protected function startLoading():void
		{
			var nb:uint = (_parallelFiles == 0 || _parallelFiles > _filesToLoad.length) ? _filesToLoad.length : _parallelFiles;
			while (numFilesLoading < nb)
			{
				var nf:ILoadManager = loadNextFile();
				if (nf == null && isComplete()) break;
			}
		}
		
		/**
		 * Register the <code>MassLoader</code> to the specified <code>ILoadManager</code>
		 * object's events.
		 * 
		 * @param	file	The file to register to.
		 * @see		#unregisterFrom()		unregisterFrom()
		 */
		protected function registerTo(file:ILoadManager):void
		{
			file.addEventListener(Event.COMPLETE, onComplete, false, LISTENER_PRIORITY, true);
			file.addEventListener(Event.OPEN, onOpen, false, LISTENER_PRIORITY, true);
			file.addEventListener(ProgressEvent.PROGRESS, onProgress, false, LISTENER_PRIORITY, true);
			file.addEventListener(Event.CLOSE, onClose, false, LISTENER_PRIORITY, true);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, LISTENER_PRIORITY, true);
			file.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, LISTENER_PRIORITY, true);
		}
		
		/**
		 * Unregister the <code>MassLoader</code> from the specified <code>ILoadManager</code>
		 * object's events.
		 * 
		 * @param	file	The file to unregister from.
		 * @see		#registerTo()		registerTo()
		 */
		protected function unregisterFrom(file:ILoadManager):void
		{
			file.removeEventListener(Event.COMPLETE, onComplete);
			file.removeEventListener(Event.OPEN, onOpen);
			file.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			file.removeEventListener(Event.CLOSE, onClose);
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			file.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		/**
		 * <code>SecurityError.SECURITY_ERROR</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onSecurityError(evt:SecurityErrorEvent):void
		{
			closeEventFile(evt);
		}
		
		/**
		 * <code>IOErrorEvent.IO_ERROR</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onIOError(evt:IOErrorEvent):void
		{
			closeEventFile(evt);
		}
		
		/**
		 * <code>Event.COMPLETE</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onComplete(evt:Event):void
		{
			loadNext(evt.target as ILoadManager, evt);
		}
		
		/**
		 * <code>Event.OPEN</code> listener. If the <code>MassLoader</code> has not been closed,
		 * the current file being open will be added to the <code>filesLoading</code> list.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onOpen(evt:Event):void
		{
			var trg:ILoadManager = evt.target as ILoadManager;
			_filesLoading.addElement(evt.target as ILoadManager);
			
			//if the MassLoad has been closed, stop the propagation
			if (!_isLoading)
			{
				stopLoadingFile(trg);
				return;
			}
		}
		
		/**
		 * <code>ProgressEvent.PROGRESS</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onProgress(evt:ProgressEvent):void
		{
			updateBytes();
			
			if (alwaysDispatchProgressEvent ||
			   _filesLoading.length >= _currentFilesLoading) //should never be greater than the _currentFilesLoading
			{
				var pg:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, evt.bubbles, evt.cancelable, bytesLoaded, bytesTotal);
				dispatchEvent(pg);
			}
		}

		/**
		 * <code>Event.CLOSE</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected final function onClose(evt:Event):void
		{
			closeEventFile(evt);
		}
		
		/**
		 * Updates the <code>bytesLoaded</code> and <code>bytesTotal</code> values.
		 */
		protected final function updateBytes():void
		{
			var loaded:uint = _tempTotalBytes;
			var total:uint = _tempTotalBytes;
			
			var length:uint = _filesToLoad.length;
			for (var i:uint=0 ; i<length ; i++)
			{
				var il:ILoadManager = _filesToLoad.getElementAt(i) as ILoadManager;
				loaded += il.bytesLoaded;
				total += il.bytesTotal;
			}
			
			_realLoadedBytes = loaded;
			_realTotalBytes = total;
			
			//update the info
			_loadInfo.update();
		}

		/**
		 * Defines if the massive loading is complete. This method will return <code>true</code> if there is no more
		 * file into the loading queue and there is currently no file loading.
		 * 
		 * @return	<code>true</code> if all the files are loaded.
		 * @see		#filesQueue	filesQueue
		 */
		protected function isComplete():Boolean
		{
			return (_filesQueue.isEmpty() && _currentFilesLoading == 0);
		}
		
		/**
		 * Processes the loading policy on the currently closed file.
		 * 
		 * @param	file		The <code>ILoadManager</code> just closed.
		 * @param	closeEvent	The event that occured.
		 * @return	The <code>ILoadManager</code> that must be reloaded or <code>null</code>.
		 */
		protected function processPolicy(file:ILoadManager, closeEvent:Event):ILoadManager
		{
			return _loadPolicy.processFile(file, closeEvent);
		}
		
		/**
		 * Retrieves the index of a file.
		 * 
		 * @param	file	The file to get the index.
		 * @return	The file index or -1 if the index is not known.
		 */
		protected function getFileIndex(file:ILoadManager):int
		{
			if (_filesIndex.containsKey(file)) return _filesIndex.getValue(file);
			return -1;
		}

		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function stopLoadingFile(file:ILoadManager):void
		{
			_currentFilesLoading--;
			file.stop();
			unregisterFrom(file);
		}
		
		/**
		 * @private
		 */
		private function closeEventFile(evt:Event):void
		{
			var trg:ILoadManager = evt.target as ILoadManager;
			if (!_isLoading)
			{
				sendCloseEvent(trg, evt);
				 return; //loading closed, stop propagation
			}
			
			//load the next file
			loadNext(trg, evt);
		}
		
		/**
		 * @private
		 */
		private function extractNextFile():ILoadManager
		{
			return _filesQueue.remove() as ILoadManager;
		}
		
		/**
		 * @private
		 */
		private function closeFile(file:ILoadManager, evt:Event):void
		{
			//unregister the file
			unregisterFrom(file);
			_filesLoading.removeElement(file);
			
			//decrement the numbe of files being loaded
			_currentFilesLoading--;
			
			/*
			It is important here to add bytesLoaded and not bytesTotal because
			if the file couldn't be loaded due to an error, bytesTotal will
			add some bytes although there is no bytes loaded.
			*/
			_tempTotalBytes += file.bytesLoaded;
			
			//removes the file
			removeFile(file);
			
			//close event
			sendCloseEvent(file, evt);
		}
		
		/**
		 * @private
		 */
		private function sendCloseEvent(file:ILoadManager, evt:Event=null):void
		{
			var index:int = getFileIndex(file);
			var op:MassLoadEvent = new MassLoadEvent(MassLoadEvent.FILE_CLOSE, file, evt, index);
			dispatchEvent(op); 
		}
		
		/**
		 * @private
		 */
		private function loadNext(file:ILoadManager = null, evt:Event = null):void
		{
			//remove the specified file
			if (file != null)
			{
				closeFile(file, evt);
				
				//apply the loading policy over the current closed file
				var f:ILoadManager = processPolicy(file, evt);
				if (f!=null)
				{
					_tempTotalBytes -= file.bytesLoaded; //readjust the bytes loaded
					_filesToLoad.addElement(f);
					loadFile(f); //launch the loading of the file specified by the load policy
					
					return;
				}
				else if (!loadPolicy.canContinue)
				{
					//oh! the loading policy doesn't allow the massive loading to continue
					stop();
					return;
				}
			}
			
			//start the loading of the files
			if (!isComplete()) startLoading();
			
			/*
			 * Redo the test isComplete because if the startLoading doesn't start
			 * any file, the doComplete method will never be called !
			 */
			if (isComplete()) doComplete();
			else if (_currentFilesLoading == 0) loadNext(); //relaunch the loading
		}
		
		/**
		 * @private
		 */
		private function doComplete():void
		{		
			_isLoading = false;
			
			//complete event
			var evt:Event = new Event(Event.COMPLETE);
			_closeEvent = evt;
			dispatchEvent(evt);
		}
	}
}

import flash.utils.getTimer;
import flash.events.Event;
import flash.utils.setTimeout;
import flash.utils.clearInterval;

import ch.capi.data.ArrayList;
import ch.capi.events.MassLoadEvent;
import ch.capi.net.ILoadInfo;
import ch.capi.net.IMassLoader;
import ch.capi.net.ILoadManager;

class MassLoadInfo implements ILoadInfo
{
	//---------//
	//Constants//
	//---------//
	private static const TIMEOUT:uint = 1500; //timeout after 1.5 sec (automatic update)
	private static const LISTENER_PRIORITY:int = 100;
	
	//---------//
	//Variables//
	//---------//
	private var _listSuccess:ArrayList		= new ArrayList();
	private var _listError:ArrayList		= new ArrayList();
	private var _listLoading:ArrayList		= new ArrayList();
	private var _listIdle:ArrayList			= new ArrayList();
	private var _massLoader:IMassLoader;
	private var _startTime:Number;
	private var _elapsedTime:uint;
	private var _remainingTime:int;
	private var _currentSpeed:Number;
	private var _averageSpeed:Number;
	
	private var _lastTimeUpdate:uint;
	private var _lastTimeBytesLoaded:uint;
	private var _privateUpdater:uint;
	
	//-----------------//
	//Getters & Setters//
	//-----------------//
	
	/**
	 * Defines the <code>IMassLoader</code> source.
	 */
	public function get massLoader():IMassLoader { return _massLoader; }
	
	/**
	 * Defines the bytes that have been loaded.
	 */
	public function get bytesLoaded():uint { return massLoader.bytesLoaded; }
	
	/**
	 * Defines the total bytes to load.
	 */
	public function get bytesTotal():uint { return massLoader.bytesTotal; }
	
	/**
	 * Defines the number of bytes to load.
	 */
	public function get bytesRemaining():uint { return bytesTotal-bytesLoaded; }
	
	/**
	 * Defines the elapsed time since the loading as begun.
	 */
	public function get elapsedTime():uint { return _elapsedTime; }

	/**
	 * Defines the remaining time, based on the speed and the bytes that left to be loaded.
	 */
	public function get remainingTime():int { return _remainingTime; }
	
	/**
	 * Defines the current speed of the download (kilobytes per seconds).
	 */
	public function get currentSpeed():Number { return _currentSpeed; }
	
	/**
	 * Defines the average speed since the loading has begun.
	 */
	public function get averageSpeed():Number { return _averageSpeed; }
	
	/**
	 * Defines a Number between 0 and 1 (included) that represents the ratio of the loaded bytes.
	 * @see	#percentLoaded	percentLoaded
	 */
	public function get ratioLoaded():Number { return (bytesTotal==0) ? 0 : bytesLoaded/bytesTotal; }
	
	/**
	 * Defines the percent of bytes loaded.
	 * @see	#ratioLoaded	ratioLoaded
	 */
	public function get percentLoaded():uint { return Math.floor(ratioLoaded*100); }
	
	/**
	 * Defines the files that have been successfully loaded.
	 */
	public function get filesSuccess():Array { return _listSuccess.toArray(); }
	
	/**
	 * Defines the files that haven't been successfully loaded.
	 */
	public function get filesError():Array { return _listError.toArray(); }
	
	/**
	 * Defines the files that are currently being loaded.
	 */
	public function get filesLoading():Array { return _listLoading.toArray(); }
	
	/**
	 * Defines the files that currently not being loaded (waits into the loading queue).
	 */
	public function get filesIdle():Array { return _listIdle.toArray(); }
	
	//-----------//
	//Constructor//
	//-----------//
	
	/**
	 * Creates a new <code>MassLoadInfo</code>.
	 * 
	 * @param	source		The source <code>IMassLoader</code>.
	 */
	public function MassLoadInfo(source:IMassLoader):void
	{
		_massLoader = source;
		_massLoader.addEventListener(Event.OPEN, onOpen, false, LISTENER_PRIORITY, true);
		_massLoader.addEventListener(MassLoadEvent.FILE_CLOSE, onFileClose, false, LISTENER_PRIORITY, true);
		_massLoader.addEventListener(MassLoadEvent.FILE_OPEN, onFileOpen, false, LISTENER_PRIORITY, true);
		_massLoader.addEventListener(Event.COMPLETE, onMassLoadClose, false, LISTENER_PRIORITY, true);
		_massLoader.addEventListener(Event.CLOSE, onMassLoadClose, false, LISTENER_PRIORITY, true);
		
		reset();
	}

	//-------------//
	//Public method//
	//-------------//
	
	/**
	 * Reset all the information.
	 */
	public function reset():void
	{
		_startTime = 0;
		_remainingTime = 0;
		_elapsedTime = 0;
		_currentSpeed = 0;
		_averageSpeed = 0;
		
		_lastTimeUpdate = 0;
		_lastTimeBytesLoaded = 0;
		
		_listError.clear();
		_listSuccess.clear();
		_listLoading.clear();
		_listIdle.clear();
		
		clearInterval(_privateUpdater);
	}

	/**
	 * Update the information.
	 */
	public function update():void
	{
		var bytesLoadedTemp:uint = bytesLoaded - _lastTimeBytesLoaded;
		var elapsedTimeTemp:uint = getTimer() - _lastTimeUpdate;
		
		if (elapsedTimeTemp > 0)
		{
			_currentSpeed = (bytesLoadedTemp/1024) / (elapsedTimeTemp/1000);
			_lastTimeBytesLoaded = bytesLoaded;
			_lastTimeUpdate = getTimer();
		}
		
		_elapsedTime = getTimer() - _startTime;
		
		if (_elapsedTime > 0) _averageSpeed = (bytesLoaded/1024) / (_elapsedTime/1000);
		else _averageSpeed = 0;
		
		if (_averageSpeed > 0) _remainingTime = Math.round(bytesRemaining/_currentSpeed);
		else _remainingTime = -1;
		
		//private updater
		clearInterval(_privateUpdater);
		if (massLoader.stateLoading) _privateUpdater = setTimeout(doUpdate, TIMEOUT);
	}
	
	/**
	 * Represents this <code>ILoadInfo</code> into a <code>String</code>.
	 * 
	 * @return Useful information into a <code>String</code>.
	 */
	public function toString():String
	{
		var data:String = "";
		data += "loaded / total : " + (_listSuccess.length+_listError.length) + "/"
								    + (_listSuccess.length+_listError.length + _listIdle.length+_listLoading.length) + "\n";
		data += "bytesTotal     : "+bytesTotal+"\n";
		data += "bytesLoaded    : "+bytesLoaded+"\n";
		data += "bytesRemaining : "+bytesRemaining+"\n";
		data += "percentLoaded  : "+percentLoaded+"% ("+Math.floor(bytesLoaded/bytesTotal*10000)/100+"%)\n";
		data += "radioLoaded    : "+Math.floor(ratioLoaded*100)/100+"\n";
		data += "currentSpeed   : "+Math.floor(currentSpeed*100)/100+" ko/sec\n";
		data += "averageSpeed   : "+Math.floor(averageSpeed*100)/100+" ko/sec\n";
		data += "elapsedTime    : "+elapsedTime+" ms\n";
		data += "remainingTime  : "+remainingTime+" ms\n";
		data += "filesIdle      : "+_listIdle.length+"\n";
		data += "filesLoading   : "+_listLoading.length+"\n";
		data += "filesSuccess   : "+_listSuccess.length+"\n";
		data += "filesError     : "+_listError.length+"\n";
		
		return data;
	}

	//-----------------//
	//Protected methods//
	//-----------------//
	
	/**
	 * Called when the massive loading starts.
	 * 
	 * @param evt Event object.
	 */
	protected function onOpen(evt:Event):void
	{
		_startTime = getTimer();
		
		//push all the files into the idle list
		var files:Array = massLoader.getFiles();
		for each(var file:ILoadManager in files)
		{
			_listIdle.addElement(file);
		}
	}
	
	/**
	 * Called when a file is closed.
	 * 
	 * @param evt	Event object.
	 */
	protected function onFileClose(evt:MassLoadEvent):void
	{ 
		var file:ILoadManager = evt.file;
		var closeEvent:Event = evt.closeEvent;
		
		_listLoading.removeElement(file);
		
		if (closeEvent == null || closeEvent.type == Event.COMPLETE) _listSuccess.addElement(file);
		else _listError.addElement(file);
	}
	
	/**
	 * Called when a file is open.
	 * 
	 * @param	evt	Event object.
	 */
	protected function onFileOpen(evt:MassLoadEvent):void
	{
		var file:ILoadManager = evt.file;
		
		//removes the file from all lists (if contained)
		_listIdle.removeElement(file);
		_listError.removeElement(file);
		_listSuccess.removeElement(file);
		
		_listLoading.addElement(file);
	}

	/**
	 * Called when the massive loading is closed or complete
	 * 
	 * @param	evt	Event object.
	 */
	protected function onMassLoadClose(evt:Event):void
	{
		//update(); //do one last update - not needed ?
		clearInterval(_privateUpdater);
	}

	//---------------//
	//Private methods//
	//---------------//
	
	/**
	 * @private
	 */
	private function doUpdate():void
	{
		//force the update
		update();
	}
}
