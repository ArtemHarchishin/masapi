package ch.capi.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.errors.IllegalOperationError;
	
	import ch.capi.data.IMap;
	import ch.capi.data.DictionnaryMap;
	
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
		private static const LISTENER_PRIORITY:int = 50;
		
		//---------//
		//Variables//
		//---------//
		private var _request:URLRequest				= null;
		private var _virtualBytesTotal:uint 		= 0;
		private var _bytesTotal:uint 				= 0;
		private var _bytesLoaded:uint 				= 0;
		private var _bytesTotalRetrieved:Boolean 	= false;
		private var _useCache:Boolean				= true;
		private var _online:String					= NetState.DYNAMIC;
		private var _stateLoading:Boolean			= false;
		private var _properties:IMap				= new DictionnaryMap();
		private var _loadManagerObject:*;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the properties stored into the
		 * <code>ILoadableFile</code>.
		 */
		public function get properties():IMap { return _properties; }
		
		/**
		 * Defines if the <code>AbstractLoadableFile</code> is loading.
		 */
		public function get stateLoading():Boolean { return _stateLoading; }
		
		/**
		 * Defines if the <code>AbstractLoadableFile</code> is idle.
		 */
		public function get stateIdle():Boolean { return !_stateLoading; }
		
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
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>AbstractLoadableFile</code> object.
		 * 
		 * @param	loadManagerObject		The <code>loadManagerObject</code>.
		 */
		public function AbstractLoadableFile(loadManagerObject:Object):void
		{			
			_loadManagerObject = loadManagerObject;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
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
		 */
		public function getURLRequest():URLRequest
		{
			if (useCache || !isOnline()) return urlRequest;
			
			var re:URLRequest = new URLRequest(urlRequest.url);
			re.method = urlRequest.method;
			re.data = urlRequest.data;
			re.requestHeaders = urlRequest.requestHeaders;
			re.contentType = urlRequest.contentType;
			
			/*
			 * I don't set the () after the Date type because else FDT generates
			 * an error saying that the number of arguments is wrong (7 expected).
			 */
			var ncValue:Number = (new Date).getTime();
			
			if (re.method == URLRequestMethod.POST || re.data == null) re.url += "?"+NO_CACHE_VARIABLE_NAME+"="+ncValue;
			else if (re.data is URLVariables)
			{
				var uv:URLVariables = re.data as URLVariables;
				uv[NO_CACHE_VARIABLE_NAME] = ncValue;
			}
			else 
			{
				var ts:String = re.data.toString();
				ts += "&"+NO_CACHE_VARIABLE_NAME+"="+ncValue;
				
				re.url += "?"+ts;
				re.data = null;
			}
			
			return re;
		}
		
		/**
		 * Retrieves if the current <code>AbstractLoadableFile</code> is online or not. If the current <code>netState</code>
		 * value is <code>NetState.DYNAMIC</code>, then  the online state is retrieved from the specified url. If the url
		 * is relative (no protocol specified), then the online state is retrieved from the current security sandbox.
		 * 
		 * @return	<code>true</code> if the <code>AbstractLoadableFile</code> is online.
		 * @see		#netState	netState
		 * @see		flash.system.Security#sandboxType	Security.sandboxType
		 */
		public function isOnline():Boolean
		{
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
		 * Stet the state as loading.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>AbstractLoadableFile</code> is already loading.
		 */
		public function start():void
		{
			if (_stateLoading) throw new IllegalOperationError("State already loading");
			_stateLoading = true;
		}
		
		/**
		 * Set the state as idle.
		 * 
		 * @throws	flash.errors.IllegalOperationError	If the <code>ILoadManager</code> is not loading.
		 */
		public function stop():void
		{
			if (!_stateLoading) throw new IllegalOperationError("State not loading");
			_stateLoading = false;
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Register the events of the <code>AbstractLoadableFile</code>.
		 * 
		 * @param	dispatcher			The <code>IEventDispatcher</code> of the events.
		 * @see		#unregisterFrom()	unregisterFrom()
		 */
		protected function registerTo(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.OPEN, onOpen, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(Event.COMPLETE, onComplete, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, onProgress, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, LISTENER_PRIORITY, true);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, LISTENER_PRIORITY, true);
		}
		
		/** 
		 * Unregister the events of the <code>AbstractLoadableFile</code>.
		 * 
		 * @param	dispatcher		The <code>IEventDispatcher</code> of the events.
		 * @see		#registerTo()	registerTo()
		 */
		protected function unregisterFrom(dispatcher:IEventDispatcher):void
		{
			dispatcher.removeEventListener(Event.OPEN, onOpen);
			dispatcher.removeEventListener(Event.COMPLETE, onComplete);
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Dispatch the close event.
		 */
		protected function close():void
		{
			var evt:Event = new Event(Event.CLOSE, false, false);
			dispatchEvent(evt);	
		}
		
		/**
		 * <code>Event.COMPLETE</code> listener.
		 * 
		 * @param	evt		The event object.
		 */
		protected function onComplete(evt:Event):void
		{
			_stateLoading = false;
			
			_bytesTotalRetrieved = true;
			_bytesTotal = _bytesLoaded;
			
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
	}
}