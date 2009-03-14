package ch.capi.net.files
{
	import flash.display.DisplayObject;	
	import flash.display.LoaderInfo;	
	import flash.utils.ByteArray;	
	import flash.events.HTTPStatusEvent;	
	import flash.system.ApplicationDomain;	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.errors.IllegalOperationError;
	import flash.utils.describeType;
	
	import ch.capi.data.text.Properties;	
	import ch.capi.display.IRootDocument;
	import ch.capi.net.ILoadableFile;	
	import ch.capi.net.NetState;	
	import ch.capi.net.INetStateManager;
	import ch.capi.data.IMap;
	import ch.capi.data.DictionnaryMap;
	import ch.capi.utils.VariableReplacer;
	
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
	 * Dispatched if a call to <code>start()</code> results in a fatal error that terminates the download. 
	 * 
	 * @eventType	flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	/**
	 * Dispatched if a call to <code>start()</code> attempts to load data from a server outside the security sandbox. 
	 * 
	 * @eventType	flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * Dispatched when data is received as the download operation progresses.
	 * 
	 * @eventType	flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * Dispatched when the http headers are received. This event isn't sent by the all the load manager objects.
	 * 
	 * @eventType	flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	
	/**
	 * Dispatched when the content of the <code>loadManagerObject</code> is displayed. This event is only dispatched if the
	 * type of <code>ILoadableFile</code> is <code>LoadableFileType.SWF</code> or when the data of a binary <code>URLLoaderFile</code> is
	 * retrieved as <code>DataType.LOADER</code>.
	 * 
	 * @eventType	flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * Represents a <code>AbstractLoadableFile</code>. This is a basic
	 * implementation to store the generic data of a <code>ILoadableFile</code>.
	 * 
	 * @see			ch.capi.net.ILoadableFile			ILoadableFile
	 * @see			ch.capi.net.LoadableFileFactory		LoadableFileFactory
	 * @author		Cedric Tabin - thecaptain
	 * @version		2.1
	 */
	public class AbstractLoadableFile extends EventDispatcher implements INetStateManager
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Name of the 'no cache' variable.
		 */
		public static const NO_CACHE_VARIABLE_NAME:String = "noCache";
		
		/**
		 * Priority of the listener.
		 * 
		 * @see		#registerEvent()		registerEvent()
		 */
		private static const LISTENER_PRIORITY:int = 100;
		
		//---------//
		//Variables//
		//---------//
		private var _request:URLRequest				= null;
		private var _virtualBytesTotal:uint 		= 0;
		private var _bytesTotal:uint 				= 0;
		private var _bytesLoaded:uint 				= 0;
		private var _bytesTotalRetrieved:Boolean 	= false;
		private var _useCache:Boolean				= true;
		private var _online:String 					= NetState.DYNAMIC;
		private var _stateLoading:Boolean			= false;
		private var _properties:Properties 			= new Properties();
		private var _urlVariables:IMap				= new DictionnaryMap();
		private var _closeEvent:Event				= null;
		private var _destroyed:Boolean				= false;
		private var _fixedRequest:URLRequest		= null;
		private var _fixedRequestUpdated:Boolean	= false;
		private var _loaded:Boolean					= false;
		private var _loadManagerObject:*;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines if the <code>ILoadManager</code> operation is complete. This
		 * value is <code>true</code> only if the data has been successfully loaded.
		 */
		public function get loaded():Boolean { return _loaded; }
		
		/**
		 * Defines the properties stored into the
		 * <code>ILoadableFile</code>.
		 * 
		 */
		public function get properties():Properties { return _properties; }
		
		/**
		 * Defines if the <code>AbstractLoadableFile</code> is loading.
		 */
		public function get stateLoading():Boolean { return _stateLoading; }
		
		/**
		 * Defines if the <code>AbstractLoadableFile</code> is idle.
		 */
		public function get stateIdle():Boolean { return !_stateLoading; }
		
		/**
		 * Defines the variables key/values to be replaced
		 * into the url before the loading is launched.
		 */
		public function get urlVariables():IMap { return _urlVariables; }
		public function set urlVariables(value:IMap):void { _urlVariables = value; }
		
		/**
		 * Defines the <code>URLRequest</code> that has been loaded by the
		 * <code>ILoadableFile</code>.
		 */
		public function get fixedRequest():URLRequest { return _fixedRequest; }
		
		/**
		 * Defines the <code>NetState</code> value. The value available can
		 * be retrieved from the <code>NetState</code> class.
		 * 
		 * @see		ch.capi.net.NetState	NetState
		 * @see		#isOnline()				isOnline()
		 */
		public function get netState():String { return _online; }
		public function set netState(value:String):void { _online = value; }
		
		/**
		 * Defines if the <code>ILoadManager</code> can use the cache or not.
		 * 
		 * @see		#getURLRequest()	getURLRequest()
		 */
		public function get useCache():Boolean { return _useCache; }
		public function set useCache(value:Boolean):void { _useCache = value; }
		
		/**
		 * Defines the bytes that have been loaded.
		 */
		public function get bytesLoaded():uint { return _bytesLoaded; }
		
		/**
		 * Defines the total bytes to load.
		 */
		public function get bytesTotal():uint { return _bytesTotal; }
		
		/**
		 * Defines if the <code>bytesTotal</code> have been retrieved.
		 */
		public function get bytesTotalRetrieved():Boolean { return _bytesTotalRetrieved; }
		
		/**
		 * Defines the <code>URLRequest</code> object that specify the
		 * URL to load.
		 */
		public function get urlRequest():URLRequest { return _request; }
		public function set urlRequest(request:URLRequest):void { _request = request; }
		
		/**
		 * Defines the virtual total bytes. This value
		 * represents an approximation of the total bytes.
		 * This value should be greather than the real amount
		 * of bytes of the loadable file.
		 */
		public function get virtualBytesTotal():uint { return _virtualBytesTotal; }
		public function set virtualBytesTotal(value:uint):void
		{
			if (!bytesTotalRetrieved) _bytesTotal = value;
			_virtualBytesTotal = value;
		}
		
		/**
		 * Defines the load manager object.
		 */
		public function get loadManagerObject():Object { return _loadManagerObject; }
		
		/**
		 * Defines the event that happend to close the file (Event.CLOSE, Event.COMPLETE, ...).
		 */
		public function get closeEvent():Event { return _closeEvent; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>AbstractLoadableFile</code> object. This method throws an error if
		 * it is directly called or if a sub-class doesn't implement the <code>ILoadableFile</code> interface.
		 * 
		 * @param	loadManagerObject		The <code>loadManagerObject</code>.
		 */
		public function AbstractLoadableFile(loadManagerObject:Object):void
		{		
			_loadManagerObject = loadManagerObject;
			
			if (! (this is ILoadableFile)) throw new IllegalOperationError("ILoableFile interface not implemented : "+this);
		}

		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Tells the <code>ILoadableFile</code> to update the <code>fixedRequest</code> value that
		 * will be used to load the file. By default, this method is automatically called when the <code>start()<code>
		 * method is executed and the <code>fixedRequest</code> hasn't been updated.
		 * 
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 */
		public function prepareFixedRequest():void
		{
			checkDestroyed();

			_fixedRequest = getURLRequest();
			_fixedRequestUpdated = true;
		}
		
		/**
		 * Invalidate the current <code>fixedRequest</code>. It means that the next time
		 * the <code>start()</code> method will be launched, the <code>ILoadableFile</code>
		 * will relaunch the loading of the data, without taking care of the cache.
		 * 
		 * @see	#fixedRequest	fixedRequest
		 */
		public function invalidateFixedRequest():void
		{
			_fixedRequestUpdated = false;
		}
		
		/**
		 * Retrieves if the current <code>AbstractLoadableFile</code> is online or not. If the current <code>netState</code>
		 * value is <code>NetState.DYNAMIC</code>, then  the online state is retrieved from the specified url. If the url
		 * is relative (no protocol specified), then the online state is retrieved from the current security sandbox.
		 * 
		 * @return	<code>true</code> if the <code>AbstractLoadableFile</code> is online.
		 * @see		#netState	netState
		 * @see		flash.system.Security#sandboxType	Security.sandboxType
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 */
		public function isOnline():Boolean
		{
			checkDestroyed();
			
			if (_online == NetState.DYNAMIC)
			{
				//try to retrieve the state from the protocol
				var u:String = urlRequest.url;
				var i:int = u.indexOf("/");
				if (i != -1) u = u.substring(0, i);

				i = u.indexOf(":");
				if (i == -1) //the url is relative (no protocol defined)
				{
					var sb:String = Security.sandboxType;
					return sb == Security.REMOTE;
				}
				
				u = u.substring(0, i);
				return u != "file";
			}
			
			return  _online == NetState.ONLINE;
		}
		
		/**
		 * Set the state as loading. This method also update the <code>fixedRequest</code> if it hasn't been done before. In any cases,
		 * the <code>fixedRequest</code> is invalidated right after the loading is started (just to ensure that the <code>fixedRequest</code>
		 * will be update the next time the <code>start()</code> method is called).
		 * 
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 * @throws	flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> is already loading.
		 */
		public final function start():void
		{
			checkDestroyed();
			if (_stateLoading) throw new IllegalOperationError("State already loading");
			
			//generate the new fixed request
			var oldFixedRequest:URLRequest = fixedRequest;
			if (!_fixedRequestUpdated) prepareFixedRequest();
			
			//check if the new generated URL is different. If not and the bytes are already loaded, then
			//the data won't be reloaded (static cache)
			if (!useCache || !isEqual(oldFixedRequest, fixedRequest) || bytesTotal <= 0 || bytesLoaded < bytesTotal)
			{
				_loaded = false;
				_stateLoading = true;
				_closeEvent = null;
		
				processLoading(fixedRequest);
			}
			
			//automatically invalidate the request after the loading is started
			invalidateFixedRequest();
		}
		
		/**
		 * Set the state as idle.
		 * 
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 * @throws	flash.errors.IllegalOperationError	If the <code>ILoadManager</code> is not loading.
		 */
		public final function stop():void
		{
			checkDestroyed();
			if (!_stateLoading) throw new IllegalOperationError("State not loading");
			
			/*
			 * Nothing to do !!
			 * It is a hack, because the Event.COMPLETE hasn't been launched at this
			 * time, so if the data is completly loaded and this method is called, then
			 * nothing is done, because the Event.COMPLETE will be sended soon.
			 */
			if (bytesLoaded == bytesTotal) return;
			
			_stateLoading = false;
			loadManagerObject.close();
			
			var evt:Event = new Event(Event.CLOSE, false, false);
			_closeEvent = evt;
			
			dispatchEvent(evt);
		}
		
		/**
		 * Retrieves if this <code>ILoadableFile</code> has been destroyed. If this method returns <code>true</code>, then
		 * no more operation is available on the <code>ILoadableFile</code>.
		 * 
		 * @return	<code>true</code> if the file has been destroyed.
		 */
		public function isDestroyed():Boolean
		{
			return _destroyed;
		}
		
		/**
		 * Destroys this <code>ILoadableFile</code>. This method causes to set the <code>loadManagerObject</code> value to
		 * <code>null</code> and releases all other references to the content loaded contained into the current <code>ILoadableFile</code>.
		 * This method also resets all the variables of the <code>ILoadableFile</code>. It just keeps a <code>URLRequest</code> with the 
		 * specified file URL.
		 * After calling this method, no more operation is available on the <code>ILoadableFile</code> instance.
		 */
		public function destroy():void
		{
			_loadManagerObject = null;
			_closeEvent = null;
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_bytesTotalRetrieved = false;
			_online = null;
			_properties = null;
			_urlVariables = null;
			_stateLoading = false;
			_useCache = false;
			_virtualBytesTotal = 0;
			_request = new URLRequest(_request.url);
			_destroyed = true;
			_fixedRequest = null;
			_fixedRequestUpdated = false;
			_loaded = false;
		}

		/**
		 * Get the URL of the <code>AbstractLoadableFile</code>.
		 * 
		 * @return	The <code>url</code> or <code>null</code> if the urlRequest is not defined.
		 */
		public override function toString():String
		{
			if (urlRequest==null) return null;
			return urlRequest.url+" ("+getType()+")";
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Retrieves the <code>URLRequest</code> that is created depending of
		 * the <code>useCache</code> property value. The creation of the <code>URLRequest</code>
		 * is based on the <code>netState</code>. If the <code>isOnline()</code> method returns
		 * <code>false</code> or the <code>useCache</code> property value is </code>true</code>, then
		 * the current <code>urlRequest</code> is returned. Else a new <code>URLRequest</code> is created,
		 * cloning the data and adding a no cache variable.
		 * 
		 * @return		The <code>URLRequest</code>
		 * @see			#useCache 	useCache
		 * @see			#isOnline()	isOnline()
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 */
		protected function getURLRequest():URLRequest
		{
			checkDestroyed();
			
			//creates a clone of the URLRequest and replaces the variables
			var newRequest:URLRequest = getUpdatedUrlRequest();
			if (useCache || !isOnline()) return newRequest;
			
			//retrieves the url data and create a unique value
			var ncValue:Number = (new Date()).getTime();
			var currentUrl:String = newRequest.url;
			var noCacheValue:String = NO_CACHE_VARIABLE_NAME+"="+ncValue;
			
			//add the no-cache variable at the end of the url
			if (currentUrl.indexOf("?") == -1) currentUrl += "?" + noCacheValue;
			else currentUrl += "&" + noCacheValue;
			
			//put the new request
			newRequest.url = currentUrl;
			
			return newRequest;
		}
		
		/**
		 * Tell the <code>ILoadableFile</code> to start the loading process. This method
		 * is supposed to be overriden by the sub-classes.
		 */
		protected function processLoading(request:URLRequest):void 
		{
			//nothing	
		}
		
		/**
		 * Register the events of the <code>AbstractLoadableFile</code>.
		 * 
		 * @param	dispatcher			The <code>IEventDispatcher</code> of the events.
		 * @see		#unregisterFrom()	unregisterFrom()
		 */
		protected function registerTo(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.INIT, onInit, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(Event.OPEN, onOpen, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(Event.COMPLETE, onComplete, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, onProgress, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus, false, LISTENER_PRIORITY, true);
		}
		
		/** 
		 * Unregister the events of the <code>AbstractLoadableFile</code>.
		 * 
		 * @param	dispatcher		The <code>IEventDispatcher</code> of the events.
		 * @see		#registerTo()	registerTo()
		 */
		protected function unregisterFrom(dispatcher:IEventDispatcher):void
		{
			dispatcher.removeEventListener(Event.INIT, onInit);
			dispatcher.removeEventListener(Event.OPEN, onOpen);
			dispatcher.removeEventListener(Event.COMPLETE, onComplete);
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
		}
		
		/**
		 * <code>Event.INIT</code> listener. This method retrieves the root <code>DisplayObject</code> associated
		 * to the <code>LoaderInfo</code> and then initializes the content.
		 * 
		 * @param	evt		The event object.
		 * @throws	ArgumentError	If the <code>Event</code> target is not a <code>LoaderInfo</code> instance.
		 */
		protected function onInit(evt:Event):void
		{
			if ( !(evt.target is LoaderInfo)) throw new ArgumentError("Invalid Event object : the target is not a LoaderInfo", evt);
			
			var src:LoaderInfo = evt.target as LoaderInfo;
			var cnt:DisplayObject = src.content;
			
			//set the linked loadable file
			if (cnt != null && cnt is IRootDocument)
			{
				var adc:IRootDocument = cnt as IRootDocument;
				adc.initializeContext(this as ILoadableFile);
			}
			
			//foward the event to the listeners
			var ne:Event = evt.clone();
			dispatchEvent(ne);
		}
		
		/**
		 * <code>Event.COMPLETE</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onComplete(evt:Event):void
		{
			_stateLoading = false;
			_closeEvent = evt;
			
			_bytesTotalRetrieved = true;
			_bytesTotal = _bytesLoaded;
			_loaded = true;
			
			var ne:Event = evt.clone();
			dispatchEvent(ne);
		}
		
		/**
		 * <code>SecurityErrorEvent</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			_stateLoading = false;
			_closeEvent = evt;
			
			var nevt:Event = evt.clone();
			dispatchEvent(nevt);
		}
		
		/**
		 * <code>IOErrorEvent</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onIOError(evt:IOErrorEvent):void
		{
			_stateLoading = false;
			_closeEvent = evt;
			
			var nevt:Event = evt.clone();
			dispatchEvent(nevt);
		}
		
		/**
		 * <code>Event.OPEN</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onOpen(evt:Event):void
		{
			var ne:Event = evt.clone();
			dispatchEvent(ne);
		}
		
		/**
		 * <code>ProgressEvent.PROGRESS</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onProgress(evt:ProgressEvent):void
		{
			_bytesTotalRetrieved = (evt.bytesTotal > 0);
			_bytesLoaded = evt.bytesLoaded;
			_bytesTotal = (_bytesTotalRetrieved) ? evt.bytesTotal : virtualBytesTotal;
			
			var ne:ProgressEvent = new ProgressEvent(evt.type, evt.bubbles, evt.cancelable, _bytesLoaded, _bytesTotal);
			dispatchEvent(ne);
		}
		
		/**
		 * <code>HTTPStatusEvent.HTTP_STATUS</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onHttpStatus(evt:HTTPStatusEvent):void
		{
			var ne:Event = evt.clone();
			dispatchEvent(ne);
		}

		/**
		 * Checks if the specified source class is a child of the specified super class.
		 * 
		 * @param	source		The source class (child).
		 * @param	superClass	The super class.
		 * @param	appDomain	The <code>ApplicationDomain</code> to retrieve the classe.
		 * @return	<code>true</code> if the source class extends the super class.
		 * 
		 * @see	#isInstanceOf()	isInstanceOf()
		 */
		protected function isInstanceOfClass(source:String, superClass:String, appDomain:ApplicationDomain=null):Boolean
		{
			return isInstanceOf(source, [superClass], appDomain);
		}
		
		/**
		 * Checks if the specified source class is a child of one of the specified super classes.
		 * 
		 * @param	source			The source class.
		 * @param	superClasses	An <code>Array</code> of <code>String</code> describing a list of classes.
		 * @param	appDomain		The <code>ApplicationDomain</code> to retrieve the classes.
		 * @return	<code>true</code> if the source class extends one of the super classes.
		 */
		protected function isInstanceOf(source:String, superClasses:Array, appDomain:ApplicationDomain=null):Boolean
		{
			//check if the class doesn't extend
			for each(var aClass:String in superClasses)
			{
				if (aClass == source) return true;
			}
			
			if (appDomain == null) appDomain = ApplicationDomain.currentDomain;
			
			var desc:XML = describeType(appDomain.getDefinition(source) as Class);
			for each(var extendsClass:String in desc.factory.extendsClass.@type)
			{
				extendsClass = extendsClass.replace("::", ".");
				for each(var superClass:String in superClasses)
				{
					if (superClass == extendsClass) return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if the current <code>ILoadableFile</code> has been destroyed and if so, throws an <code>IllegalOperationError</code>.
		 * 
		 * @throws  flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> has been destroyed.
		 */
		protected function checkDestroyed():void
		{
			if (isDestroyed()) throw new IllegalOperationError("The file [ "+this+" ] has been destroyed");
		}
		
		/**
		 * Creates a clone of the current <code>URLRequest</code> and put the variables values into its data.
		 * If there is some 
		 * 
		 * @return	The new <code>URLRequest</code>.
		 */
		protected function getUpdatedUrlRequest():URLRequest
		{
			var replacer:VariableReplacer = new VariableReplacer(_urlVariables);

			var newRequest:URLRequest = new URLRequest();
			newRequest.url = replacer.replaceVars(urlRequest.url); //perform variable replacement
			newRequest.method = urlRequest.method;
			newRequest.requestHeaders = urlRequest.requestHeaders;
			newRequest.contentType = urlRequest.contentType;
			
			//replaces the variable into the data
			var data:Object = urlRequest.data;
			if (data != null && !(data is ByteArray))
			{
				var strData:String = data.toString();
				strData = replacer.replaceVars(strData);
				data = strData;
			}
			newRequest.data = data;
			
			return newRequest;
		}
		
		/**
		 * Checks if data has been loaded and is available to be retrieved. If not, then an <code>Error</code>
		 * will be thrown. This method is useful to get direct information about why the data couldn't be retrieved.
		 * 
		 * @throws	Error	If the data are not loaded.
		 */
		protected function checkData():void
		{
			if (!loaded)
			{
				//basic message
				var message:String = "Data not loaded\n  file : "+this+"\n";
				
				//fixedRequest information
				message += "  fixedRequest : ";
				if (fixedRequest == null) message += "null\n";
				else message += fixedRequest.url+"\n";
				
				//closeEvent information
				message += "  closeEvent : ";
				if (closeEvent == null) message += "null";
				else
				{
					message += closeEvent.type;
					
					//more details if the closeEvent is an error event
					if (closeEvent is IOErrorEvent) message += " ("+(closeEvent as IOErrorEvent).text+")";
					else if (closeEvent is SecurityErrorEvent) message += " ("+(closeEvent as SecurityErrorEvent).text+")";
					message += "\n";
				}
				
				//and throw it !!!
				throw new Error(message);
			}
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function getType():String
		{
			return (this as ILoadableFile).getType();
		}
		
		/**
		 * @private
		 */
		private function isEqual(a:URLRequest, b:URLRequest):Boolean
		{
			if (a == null || b == null) return false;
			return a.url == b.url;
		}
	}
}
