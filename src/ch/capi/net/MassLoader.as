package ch.capi.net
{
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
	 * @see			ch.capi.net.LoadableFileFactory	LoadableFileFactory
	 * @see			ch.capi.net.CompositeMassLoader	CompositeMassLoader
	 * @see			ch.capi.net.PriorityMassLoader	PriorityMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.1
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
		private static const LISTENER_PRIORITY:int = -10;
		
		//---------//
		//Variables//
		//---------//
		private var _filesQueue:IDataStructure			= new QueueList();
		private var _filesToLoad:IList					= new ArrayList();
		private var _filesLoading:IList					= new ArrayList();
		private var _isLoading:Boolean					= false;
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
		 */
		public var alwaysDispatchProgressEvent:Boolean = false;
		
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
		 * Defines if the <code>MassLoader</code> can use the cache or not. Note that if this property
		 * is set to <code>false</code>, it will override all the other <code>ILoadManager.useCache</code> value
		 * and reload them.
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
		 */
		public function get numFilesLoading():uint { return _currentFilesLoading; }
		
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
			
			//init
			_tempTotalBytes = 0;
			_currentFilesLoading = 0;
			_filesLoading.clear(); //empty the files being loaded
			_filesQueue.clear(); //empty the files queue to load
			
			//put all the files into the queue
			var l:uint = _filesToLoad.length;
			for (var i:uint=0 ; i<l ; i++) _filesQueue.add(_filesToLoad.getElementAt(i));
			
			//update the current loaded values
			updateBytes();
			
			//open event
			var evt:Event = new Event(Event.OPEN);
			dispatchEvent(evt);
			
			//check the number of files
			if (_filesQueue.isEmpty()) doComplete();
			else loadNext();
		}
		
		/**
		 * Empty the loading queue. This will not affect the current loading.
		 */
		public function clear():void
		{
			_filesToLoad.clear();
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
			var op:MassLoadEvent = new MassLoadEvent(MassLoadEvent.FILE_OPEN, file);
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
			
			//if the MassLoad has been closed, stop the propagation
			if (!_isLoading)
			{
				stopLoadingFile(trg);
				return;
			}
			
			_filesLoading.addElement(evt.target as ILoadManager);
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
			   _filesLoading.length == _currentFilesLoading)
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
		}
		
		/**
		 * Defines if the massive loading is complete.
		 * 
		 * @return	<code>true</code> if all the files are loaded.
		 */
		protected function isComplete():Boolean
		{
			return (_filesQueue.isEmpty() && _currentFilesLoading == 0);
		}
		
		/**
		 * Callback method called after the <code>ILoadPolicy</code> has been applied. This method manages if the
		 * processed file must be reloaded or not. This method is only called when the <code>ILoadPolicy</code> returns
		 * a non-<code>null</code> value (ie a <code>ILoadManager</code> to reload).
		 * <p>By default, this method returns <code>true</code>.</p>
		 * 
		 * @param	fileSource		The source <code>ILoadManager</code> that has been loaded (successfully or not).
		 * @param	fileProcessed	The <code>ILoadManager</code> returned by the <code>ILoadPolicy</code> when processing the <code>fileSource</code>.
		 * @return	<code>true</code> if the processed file must be reloaded, <code>false</code> otherwise.
		 */
		protected function reloadFile(fileSource:ILoadManager, fileProcessed:ILoadManager):Boolean
		{
			return false;
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
				closeEvent(trg, evt);
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
			closeEvent(file, evt);
		}
		
		/**
		 * @private
		 */
		private function closeEvent(file:ILoadManager, evt:Event=null):void
		{
			var op:MassLoadEvent = new MassLoadEvent(MassLoadEvent.FILE_CLOSE, file, evt);
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
				var f:ILoadManager = _loadPolicy.processFile(file, evt);
				if (f!=null && !reloadFile(file, f))
				{
					_tempTotalBytes -= file.bytesLoaded; //readjust the bytes loaded
					_filesToLoad.addElement(f);
					loadFile(f); //launch the loading of the file specified by the load policy
					
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
			dispatchEvent(evt);
		}
	}
}