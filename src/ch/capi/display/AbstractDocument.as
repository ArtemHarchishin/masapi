package ch.capi.display
{
	import ch.capi.net.INetStateManager;
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.NetState;
	import ch.capi.display.IRootDocument;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	
	/**
	 * Basic implementation of an <code>IRootDocument</code> and <code>INetStateManager</code>.
	 * <p>Note that you should <strong>never</strong> use this class directly as a DocumentClass.</p>
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class AbstractDocument extends MovieClip implements IRootDocument, INetStateManager
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
		 * Defines the <code>ILoadableFile</code> used to load this document.
		 * 
		 * @see #initializeContext() initializeContext method
		 */
		public function get loadableFile():ILoadableFile { return _linkedFile; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>AbstractDocument</code> object.
		 */
		public function AbstractDocument():void
		{
			if (stage != null) stage.align = StageAlign.TOP_LEFT;
			netState = NetState.get();
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
			return !(netState == NetState.OFFLINE);
		}
		
		/**
		 * Callback of the MassLoader (<code>IRootDocument</code> interface). This method should
		 * be overriden to implement the initialization tasks.
		 * 
		 * @param	loadableFile	The <code>ILoadableFile</code> source.
		 * @see		#loadableFile	loadableFile
		 */
		public function initializeContext(loadableFile:ILoadableFile):void
		{
			_linkedFile = loadableFile;
		}
	}
}