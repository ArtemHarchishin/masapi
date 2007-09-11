package ch.capi.display
{
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.NetState;
	import ch.capi.core.IApplicationContext;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.system.Security;
	
	/**
	 * Basic implementation of an <code>IApplicationContext</code>.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class AbstractDocument extends MovieClip implements IApplicationContext
	{
		//---------//
		//Variables//
		//---------//
		private var _linkedFile:ILoadableFile;
		private var _netState:String;

		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>NetState</code> value. The value available can
		 * be retrieved from the <code>NetState</code> class.
		 * 
		 * @see		ch.capi.net.NetState	NetState
		 * @see		#isOnline()				isOnline()
		 */
		public function get netState():String { return _netState; }
		public function set netState(value:String):void { _netState = value; }
		
		/**
		 * Defines the <code>ILoadableFile</code> of the document. This value is set when the
		 * <code>Event.INIT</code> event is dispatched from the <code>ILoadableFile</code> where
		 * it is loaded. If the document isn't loaded using a Loader <code>ILoadableFile</code>
		 * (<code>LoadableFileFactory.createLoaderFile()), then this value won't be initialized.
		 * 
		 * @see		ch.capi.net.LoadableFileFactory#createLoaderFile()	LoadableFileFactory.createLoaderFile()
		 */
		public function get linkedLoadableFile():ILoadableFile { return _linkedFile; }
		public function set linkedLoadableFile(value:ILoadableFile):void { _linkedFile = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>AbstractDocument</code> object.
		 */
		public function AbstractDocument():void
		{
			if (stage != null) stage.align = StageAlign.TOP_LEFT;
			netState = NetState.DYNAMIC;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the state depending of the <code>NetState</code>
		 * value defined.
		 * <p>If the <code>netState</code> value is <code>NetState.ONLINE</code>, then this
		 * method returns <code>true</code>. If the <code>netState</code> value is <code>NetState.OFFLINE</code>,
		 * then this method returns <code>false</code>. If the <code>netState</code> value is
		 * <code>NetState.DYNAMIC</code>, then this method uses the <code>Security.sandboxType</code> to determines
		 * if the online state.</p>
		 * 
		 * @return	<code>true</code> if the <code>INetStateManager</code> is online or not.
		 * @see		#netState	Define the online state
		 * @see		flash.system.Security#sandboxType	Security.sandboxType
		 */
		public function isOnline():Boolean
		{
			if (netState == NetState.DYNAMIC)
			{
				var s:String = Security.sandboxType;
				return (s == Security.REMOTE);
			}
			
			return netState == NetState.ONLINE;
		}
	}
}