package ch.capi.events
{
	import ch.capi.net.ILoadManager;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * Represents an event occuring during a massloading.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class MassLoadEvent extends Event
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Event when the loading of a file starts.
		 */
		public static const FILE_OPEN:String = "fileOpen";
		
		/**
		 * Event when the loading of a file stops.
		 */
		public static const FILE_CLOSE:String = "fileClose";
		
		//---------//
		//Variables//
		//---------//
		private var _file:ILoadManager;
		private var _closeEvent:Event;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the file being loaded.
		 */
		public function get file():ILoadManager { return _file; }
		
		/**
		 * Defines the event that occured when the file was closed.
		 */
		public function get closeEvent():Event { return _closeEvent; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>MassLoadEvent</code> object.
		 * 
		 * @param	type		The type.
		 * @param	file		The file being loaded.
		 * @param	closeEvent	The <code>Event</code> dispatched to close the file. This event is cloned before beeing stored.
		 */
		public function MassLoadEvent(type:String, file:ILoadManager=null, closeEvent:Event=null):void
		{
			super(type, false, false);
			
			_file = file;
			_closeEvent = (closeEvent==null) ? null : closeEvent.clone();
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a copy of the <code>MassLoadEvent</code> object and sets the value of each property to match that of the original.
		 * 
		 * @return	The cloned <code>Event</code>.
		 */
		public override function clone():Event
		{
			return new MassLoadEvent(type, file, _closeEvent);
		}
		 
		/**
		 * Get if an error has occured during the download of the specified file. If the error event is a
		 * <code>IOErrorEvent</code> or a <code>SecurityErrorEvent</code>, then the value <code>true</code> is
		 * returned.
		 * 
		 * @return	<code>true</code> if there was an error. A <code>FILE_OPEN</code> event always return <code>false</code>.
		 * @see		#closeEvent	closeEvent
		 */
		public function isError():Boolean
		{
			if (type == FILE_OPEN) return false;
			return (_closeEvent is IOErrorEvent || _closeEvent is SecurityErrorEvent);
		}
	}
}