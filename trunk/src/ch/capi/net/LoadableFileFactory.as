package ch.capi.net
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * Factory of <code>ILoadableFile</code> objects.
	 * 
	 * @example
	 * Basic usage of the <code>LoableFileFactory</code> :
	 * <listing version="3.0">
	 * var factory:LoadableFileFactory = new LoadableFileFactory();
	 * var file:ILoadableFile = factory.create("myFile.swf"); //creates a Loader-based ILoadableFile
	 * 
	 * //retrieves the load manager object
	 * var lo:Loader = file.loadManagerObject as Loader;
	 * </listing>
	 * 
	 * @example
	 * Advanced usage of the <code>LoableFileFactory</code> :
	 * <listing version="3.0">
	 * var selector:ExtensionFileSelector = new ExtensionFileSelector();
	 * selector.extensions.put("swf", LoadableFileType.BINARY);
	 * 
	 * var factory:LoadableFileFactory = new LoadableFileFactory(selector);
	 * var file:ILoadableFile = factory.create("myFile.swf"); //creates a binary URLLoader-based ILoadableFile
	 * 
	 * //retrieves the load manager object
	 * var ulo:URLLoader = file.loadManagerObject as URLLoader;
	 * </listing>
	 * 
	 * @see			ch.capi.net.ILoadableFile 			ILoadableFile
	 * @see			ch.capi.net.ILoadableFileSelector	ILoadableFileSelector
	 * @see			ch.capi.net.LoadableFileType		LoadableFileType
	 * @see			ch.capi.net.IMassLoader				IMassLoader
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.0
	 */
	public class LoadableFileFactory
	{
		//---------//
		//Variables//
		//---------//
		private var _defaultVirtualBytes:uint;
		private var _useCache:Boolean;
		private var _fileSelector:ILoadableFileSelector;
		private var _listenersPriority:int;

		/**
		 * Defines the base path that will be used as prefix when a <code>URLRequest</code> is created.
		 * 
		 * @see	#create()	create()
		 */
		public var basePath:String = null;

		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the listeners priority when the <code>attachListeners</code> method is used.
		 * 
		 * @param	#attachListeners()		attachListeners()
		 */
		public function get listenersPriority():int { return _listenersPriority; }
		public function set listenersPriority(value:int):void {	_listenersPriority = value; }
		
		/**
		 * Defines the <code>ILoadableFileSelector</code> that will be used when the
		 * <code>create</code> or <code>createFile</code> method is called.
		 * 
		 * @see		#create()		create()
		 * @see		#createFile()	createFile()
		 */
		public function get loadableFileSelector():ILoadableFileSelector { return _fileSelector; }
		public function set loadableFileSelector(value:ILoadableFileSelector):void { _fileSelector = value; }
		
		/**
		 * Defines if the <code>ILoadableFile</code> created will use the
		 * cache or not.
		 * 
		 * @see		ch.capi.net.ILoadManager#useCache	ILoadManager.useCache
		 */
		public function get defaultUseCache():Boolean { return _useCache; }
		public function set defaultUseCache(value:Boolean):void { _useCache = value; }
		
		/**
		 * Defines the default virtual bytes to set to the created <code>ILoadableFile</code>
		 * objects.
		 * 
		 * @see		ch.capi.net.ILoadableFile#virtualBytesTotal	ILoadableFile.virtualBytesTotal
		 */
		public function get defaultVirtualBytesTotal():uint { return _defaultVirtualBytes; }
		public function set defaultVirtualBytesTotal(value:uint):void { _defaultVirtualBytes = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>LoadableFileFactory</code> object.
		 * 
		 * @param	fileSelector				The <code>ILoadableFileSelector</code>. By default, a <code>ExtensionFileSelector</code>
		 * 										will be created.
		 * @param	defaultUseCache				Indicates if the <code>ILoadableFile</code>
		 * 										will use the cache or not.
		 * @param	defaultVirtualBytesTotal	The virtual bytes to set by default to the
		 * 										created <code>ILoadableFile</code> objects.
		 * @param	listenersPriority			Defines the listeners priority when the <code>attachListeners</code>
		 * 										method is used.
		 * 										
		 * @see		ch.capi.net.ExtensionFileSelector	ExtensionFileSelector
		 */
		public function LoadableFileFactory(fileSelector:ILoadableFileSelector=null,
											defaultUseCache:Boolean=true,  
											defaultVirtualBytesTotal:uint = 204800,
											listenersPriority:int = 0):void
		{
			_fileSelector = (fileSelector==null) ? new ExtensionFileSelector() : fileSelector;
			_defaultVirtualBytes = defaultVirtualBytesTotal;
			_useCache = defaultUseCache;
			_listenersPriority = listenersPriority;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a <code>ILoadableFile</code> associated to a <code>URLLoader</code>
		 * object.
		 * 
		 * @param	request		The url request.
		 * @param	dataFormat	The format of the data issued from the <code>URLLoaderDataFormat</code> constants.
		 * @return	The <code>ILoadableFile</code> object created.
		 */
		public function createURLLoaderFile(request:URLRequest=null, dataFormat:String=null):ILoadableFile
		{
			var ldr:URLLoader = new URLLoader();
			var ldb:ULoadableFile = new ULoadableFile(ldr);
			ldb.urlRequest = request;
			
			if (dataFormat != null) ldr.dataFormat = dataFormat;
			initializeFile(ldb);
			
			return ldb;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> associated to a <code>URLStream</code>
		 * object.
		 * 
		 * @param	request		The url request.
		 * @return	The <code>ILoadableFile</code> object created.
		 */
		public function createURLStreamFile(request:URLRequest=null):ILoadableFile
		{
			var lds:URLStream = new URLStream();
			var ids:RLoadableFile = new RLoadableFile(lds);
			ids.urlRequest = request;
			
			initializeFile(ids);
			
			return ids;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> associated to a <code>Sound</code>
		 * object.
		 * 
		 * @param	request		The url request.
		 * @param	context		The <code>SoundLoaderContext</code>.
		 * @return	The <code>ILoadableFile</code> object created.
		 */
		public function createSoundFile(request:URLRequest=null, context:SoundLoaderContext=null):ILoadableFile
		{
			var snd:Sound = new Sound();
			var sld:SLoadableFile = new SLoadableFile(snd);
			sld.urlRequest = request;
			
			if (context != null) sld.soundLoaderContext = context;
			initializeFile(sld);
			
			return sld;
		}
		
		/**
		 * Create a <code>ILoadableFile</code> associated to a <code>Loader</code> object.
		 * 
		 * @param	request				The url request.
		 * @param	context				The <code>LoaderContext</code>.
		 * @return	The <code>ILoadableFile</code> object created.
		 */
		public function createLoaderFile(request:URLRequest=null, context:LoaderContext=null):ILoadableFile
		{
			var ldr:Loader = new Loader();
			var ldb:LLoadableFile = new LLoadableFile(ldr);
			ldb.urlRequest = request;

			if (context != null) ldb.loaderContext = context;
			initializeFile(ldb);
			
			return ldb;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> using the defined <code>ILoadableFileSelector</code> to determine
		 * which type of <code>ILoadableFile</code> to create.
		 * 
		 * @param	request		The url request.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The <code>ILoadableFile</code> object created or <code>null</code> if the
		 * 			<code>ILoadableFile</code> has not been created.
		 * @see		#attachListeners	attachListeners
		 */
		public function createFile(request:URLRequest,
								   onOpen:Function=null, 
								   onProgress:Function=null, 
								   onComplete:Function=null, 
								   onClose:Function=null,
								   onIOError:Function=null,
								   onSecurityError:Function=null):ILoadableFile
		{
			var file:ILoadableFile = loadableFileSelector.create(request, this);
			if (file == null) return null;
			
			attachListeners(file, onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			
			return file;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> directly from an url. This method will simply
		 * create a <code>URLRequest</code> object and return the <code>ILoadableFile</code> retrieved
		 * by the <code>createFile()</code> method.
		 * 
		 * @param	url			The url. If a <code>basePath</code> is set, then the url will be <code>basePath + url</code>.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The <code>ILoadableFile</code> object created.
		 * @see		#attachListeners()	attachListeners()
		 */
		public function create(url:String,
							   onOpen:Function=null, 
							   onProgress:Function=null, 
							   onComplete:Function=null, 
							   onClose:Function=null,
							   onIOError:Function=null,
							   onSecurityError:Function=null):ILoadableFile
		{
			if (basePath != null)
			{
				if (basePath.charAt(basePath.length-1) != "/") basePath += "/";
				url = basePath + url;
			}
			
			return createFile(new URLRequest(url), onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
		}
		
		/**
		 * Creates  the listeners on a <code>ILoadManager</code> object.
		 * 
		 * @param	file		The <code>ILoadManager</code> to listen.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @see		#listenersPriority	listenersPriority()
		 */
		public function attachListeners(file:ILoadableFile,
									    onOpen:Function=null, 
									    onProgress:Function=null, 
									    onComplete:Function=null, 
									    onClose:Function=null,
							   			onIOError:Function=null,
							   			onSecurityError:Function=null):void
		{
			createListener(Event.OPEN, file, onOpen);
			createListener(Event.COMPLETE, file, onComplete);
			createListener(ProgressEvent.PROGRESS, file, onProgress);
			createListener(Event.CLOSE, file, onClose);
			createListener(IOErrorEvent.IO_ERROR, file, onIOError);
			createListener(SecurityErrorEvent.SECURITY_ERROR, file, onSecurityError);
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Initialize the default data of the specified <code>ILoadableFile</code>.
		 * 
		 * @param	file	The <code>ILoadableFile</code> to initialize.
		 */
		protected function initializeFile(file:ILoadableFile):void
		{
			file.virtualBytesTotal = _defaultVirtualBytes;
			file.useCache = _useCache;
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		 private function createListener(evtName:String, file:ILoadManager, listener:Function):void
		 {
		 	if (listener != null)
		 	{
		 		file.addEventListener(evtName, listener, false, _listenersPriority, true);
		 	}
		 }
	}
}