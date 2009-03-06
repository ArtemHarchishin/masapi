package ch.capi.net
{
	import ch.capi.data.TreeMap;	
	import ch.capi.data.DictionnaryMap;	
	import ch.capi.data.IMap;	
	import ch.capi.net.files.*;

	import flash.system.ApplicationDomain;	
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
	import flash.utils.getQualifiedClassName;
		
	/**
	 * Factory of <code>ILoadableFile</code> objects.
	 * 
	 * @example
	 * <listing version="3.0">
	 * var file1:ILoadableFile = LoadableFileFactory.create("file.swf"); //use a Loader
	 * var file2:ILoadableFile = LoadableFileFactory.create("file.swf", LoadableFileType.BINARY); //use a URLLoader with URLLoaderDataFormat.BINARY 
	 * 
	 * var myRequest:URLRequest = new URLRequest("file.txt");
	 * var file3:ILoadableFile = LoadableFileFactory.create(myRequest);
	 * </listing>
	 * 
	 * @see			ch.capi.net.ILoadableFile 			ILoadableFile
	 * @see			ch.capi.net.FileTypeSelector		FileTypeSelector
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
		private static var __defaultFactory:LoadableFileFactory		= new LoadableFileFactory();
		private var _defaultVariables:IMap 							= new DictionnaryMap(true);
		private var _defaultLoaderContext:LoaderContext				= new LoaderContext(false, ApplicationDomain.currentDomain);
		private var _defaultSoundLoaderContext:SoundLoaderContext	= new SoundLoaderContext();
		private var _defaultVirtualBytes:uint;
		private var _useCache:Boolean;
		private var _fileSelector:FileTypeSelector;
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
		 * Defines the default <code>LoadableFileFactory</code>.
		 * 
		 * @see		#create()	create()
		 */
		public static function get defaultLoadableFileFactory():LoadableFileFactory { return __defaultFactory; }
		
		/**
		 * Defines the listeners priority when the <code>attachListeners</code> method is used.
		 * 
		 * @param	#attachListeners()		attachListeners()
		 */
		public function get listenersPriority():int { return _listenersPriority; }
		public function set listenersPriority(value:int):void {	_listenersPriority = value; }
		
		/**
		 * Defines the <code>FileTypeSelector</code> that will be used when the
		 * <code>createFile</code> method is called.
		 * 
		 * @see		#createFile()		createFile()
		 */
		public function get fileTypeSelector():FileTypeSelector { return _fileSelector; }
		public function set fileTypeSelector(value:FileTypeSelector):void { _fileSelector = value; }
		
		/**
		 * Defines the default variables that will be used by the created <code>ILoadableFile</code> instances as
		 * parent <code>IMap</code>. The <code>LoadableFileFactory</code> will create a <code>TreeMap</code> for each
		 * <code>ILoadableFile</code> with this <code>IMap</code> as parent. 
		 * 
		 * @see		ch.capi.net.ILoadableFile#urlVariables ILoadableFile.urlVariables
		 * @see		ch.capi.dataTreeMap	TreeMap	
		 */
		public function get defaultVariables():IMap { return _defaultVariables; }
		public function set defaultVariables(value:IMap):void
		{
			if (value == null) throw new ArgumentError("The value is not defined");
			_defaultVariables = value;
		}

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
		
		/**
		 * Defines the default <code>LoaderContext</code> that will be used to create a <code>ILoadableFile</code>
		 * based on a <code>Loader</code> object.
		 * 
		 * @see		#createLoaderFile()		createLoaderFile()
		 */
		public function get defaultLoaderContext():LoaderContext { return _defaultLoaderContext; }
		public function set defaultLoaderContext(value:LoaderContext):void
		{
			if (value == null) throw new ArgumentError("value is not defined");
			_defaultLoaderContext = value;
		}
		
		/**
		 * Defines the defaut <code>SoundLoaderContext</code> that will be used to create a <code>ILoadableFile</code>
		 * based on a <code>Sound</code> object.
		 * 
		 * @see		#createSoundFile()		createSoundFile()
		 */
		public function get defaultSoundLoaderContext():SoundLoaderContext { return _defaultSoundLoaderContext; }
		public function set defaultSoundLoaderContext(value:SoundLoaderContext):void
		{
			if (value == null) throw new ArgumentError("value is not defined");
			_defaultSoundLoaderContext = value;
		}

		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>LoadableFileFactory</code> object.
		 * 
		 * @param	fileSelector				The <code>FileTypeSelector</code>. If not defined, the 
		 * 										<code>FileTypeSelector.defaultFileTypeSelector</code> will be used.
		 * @param	defaultUseCache				Indicates if the <code>ILoadableFile</code>
		 * 										will use the cache or not.
		 * @param	defaultVirtualBytesTotal	The virtual bytes to set by default to the
		 * 										created <code>ILoadableFile</code> objects.
		 * @param	listenersPriority			Defines the listeners priority when the <code>attachListeners</code>
		 * 										method is used.
		 */
		public function LoadableFileFactory(fileSelector:FileTypeSelector=null,
											defaultUseCache:Boolean=true,  
											defaultVirtualBytesTotal:uint = 204800,
											listenersPriority:int = 0):void
		{
			_fileSelector = (fileSelector==null) ? FileTypeSelector.defaultFileTypeSelector : fileSelector;
			_defaultVirtualBytes = defaultVirtualBytesTotal;
			_useCache = defaultUseCache;
			_listenersPriority = listenersPriority;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a <code>ILoadableFile</code> object.
		 * 
		 * @param	url		The url of the file.
		 * @param	type	The file type issued from the <code>LoadableFileType</code> constants.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The created <code>ILoadableFile</code> object.
		 * 
		 * @see	#getRequest()				getRequest()
		 * @see	#defaultLoadableFileFactory	defaultLoadableFileFactory
		 */
		public static function create(url:Object,
								      type:String=null,
								      onOpen:Function=null, 
								      onProgress:Function=null, 
								      onComplete:Function=null, 
								      onClose:Function=null,
								      onIOError:Function=null,
								      onSecurityError:Function=null):ILoadableFile
		{
			return __defaultFactory.createFile(url, type, onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
		}

		/**
		 * Creates a <code>URLRequest</code> from a url object. If the url is a <code>URLRequest</code>, then it is simply
		 * returned. If the url is a <code>String</code>, it is encapsulated in a new <code>URLRequest</code>. Otherwise, an
		 * error is thrown.
		 * 
		 * @param	url		The url object.
		 * @return	The created <code>URLRequest</code> object.
		 * @throws	ArgumentError	If the url is not a <code>URLRequest</code> nor a <code>String</code>.
		 */
		public static function getRequest(url:Object):URLRequest
		{
			if (url is URLRequest) return url as URLRequest;
			if (url is String) return new URLRequest(url as String);
			
			throw new ArgumentError("Unrecognized object : "+getQualifiedClassName(url)+" => "+url);
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> associated to a <code>URLLoader</code>
		 * object.
		 * 
		 * @param	request		The url request.
		 * @param	dataFormat	The format of the data issued from the <code>URLLoaderDataFormat</code> constants.
		 * @return	The <code>ILoadableFile</code> object created.
		 */
		public function createURLLoaderFile(request:URLRequest=null, dataFormat:String=null):URLLoaderFile
		{
			var ldr:URLLoader = new URLLoader();
			var ldb:URLLoaderFile = new URLLoaderFile(ldr);
			ldb.urlRequest = request;
			ldb.loaderContext = defaultLoaderContext;
			
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
		public function createURLStreamFile(request:URLRequest=null):URLStreamFile
		{
			var lds:URLStream = new URLStream();
			var ids:URLStreamFile = new URLStreamFile(lds);
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
		public function createSoundFile(request:URLRequest=null, context:SoundLoaderContext=null):SoundFile
		{
			var snd:Sound = new Sound();
			var sld:SoundFile = new SoundFile(snd);
			sld.urlRequest = request;
			
			if (context == null) context = _defaultSoundLoaderContext;
			sld.soundLoaderContext = context;
			
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
		public function createLoaderFile(request:URLRequest=null, context:LoaderContext=null):LoaderFile
		{
			var ldr:Loader = new Loader();
			var ldb:LoaderFile = new LoaderFile(ldr);
			ldb.urlRequest = request;

			if (context == null) context = _defaultLoaderContext;
			ldb.loaderContext = context;
			
			initializeFile(ldb);
			
			return ldb;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> directly from an url.
		 * 
		 * @param	url			The url. If a <code>basePath</code> is set, then the url will be <code>basePath + url</code>.
		 * @param	type	The file type issued from the <code>LoadableFileType</code> constants.
		 * @param	onOpen		The <code>Event.OPEN</code> listener.
		 * @param	onProgress	The <code>ProgressEvent.PROGRESS</code> listener.
		 * @param	onComplete	The <code>Event.COMPLETE</code> listener.
		 * @param	onClose		The <code>Event.CLOSE</code> listener.
		 * @param	onIOError	The <code>IOErrorEvent.IO_ERROR</code> listener.
		 * @param	onSecurityError The <code>SecurityErrorEvent.SECURITY_ERROR</code> listener.
		 * @return	The <code>ILoadableFile</code> object created.
		 * @see		#attachListeners()	attachListeners()
		 * @see		#getRequest()		getRequest()
		 */
		public function createFile(url:Object,
								   type:String=null,
								   onOpen:Function=null, 
								   onProgress:Function=null, 
								   onComplete:Function=null, 
								   onClose:Function=null,
								   onIOError:Function=null,
								   onSecurityError:Function=null):ILoadableFile
		{
			//creates the request
			var request:URLRequest = getRequest(url);
			if (basePath != null)
			{
				if (basePath.charAt(basePath.length-1) != "/") basePath += "/";
				request.url = basePath + request.url;
			}
			
			//retrieves the type if not specified and create the ILoadableFile
			if (type == null) type = fileTypeSelector.getType(request);
			var method:Function = getMethod(type);
			
			if (method == null) throw new ArgumentError("File type not supported : '"+request.url+"' ("+type+")");
			else if (method == createFile) throw new ArgumentError("Recusive method call (createFile). Probably the file type not supported : '"+request.url+"' ("+type+")");
			
			var file:ILoadableFile = method(request);
			if (file == null) return null;
			
			attachListeners(file, onOpen, onProgress, onComplete, onClose, onIOError, onSecurityError);
			return file;
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
		
		/**
		 * Creates a clone of the current <code>LoadableFileFactory</code>. This method will only clone the
		 * current <code>LoadableFileFactory</code> and report its references into the new one.
		 * 
		 * @return	The cloned <code>LoadableFileFactory</code>.
		 */
		public function clone():LoadableFileFactory
		{
			var ncl:LoadableFileFactory = new LoadableFileFactory();
			ncl._defaultLoaderContext = _defaultLoaderContext;
			ncl._defaultSoundLoaderContext = _defaultSoundLoaderContext;
			ncl._defaultVariables = _defaultVariables;
			ncl._defaultVirtualBytes = _defaultVirtualBytes;
			ncl._fileSelector = _fileSelector;
			ncl._listenersPriority = _listenersPriority;
			ncl._useCache = _useCache;
			ncl.basePath = basePath;
			return ncl;
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
			file.urlVariables = new TreeMap(_defaultVariables);
			file.virtualBytesTotal = _defaultVirtualBytes;
			file.useCache = _useCache;
		}
		
		/**
		 * Retrieves the method to call within the specified type to create a <code>ILoadableFile</code>. All functions
		 * returned by this method take a <code>URLRequest</code> as first argument.
		 * 
		 * @param	type	The type issued from the <code>LoadableFileType</code> constants.
		 * @return	The method to call.
		 * @throws	ArgumentError	If the type is invalid.
		 */
		protected function getMethod(type:String):Function
		{
			switch(type)
			{
				case LoadableFileType.BINARY:
				case LoadableFileType.TEXT:
				case LoadableFileType.VARIABLES:
				
					//create a closure to send the right dataFormat to the method
					return function(request:URLRequest, fileType:String=null):ILoadableFile
					{
						if (fileType == null) fileType = type;
						return createURLLoaderFile(request, fileType);
					};
				
				case LoadableFileType.SWF:
					return createLoaderFile;
					
				case LoadableFileType.SOUND:
					return createSoundFile;
					
				case LoadableFileType.STREAM:
					return createURLStreamFile;
					
				case null: //be careful with that (recursive problems can appear)
					return createFile;
			}
			
			throw new ArgumentError("The file type '"+type+"' is not valid");
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