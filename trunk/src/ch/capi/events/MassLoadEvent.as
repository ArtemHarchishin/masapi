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
		private var _index:int;
		
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
		
		/**
		 * Defines the index of the file. The index is unique for a <code>ILoadableFile</code>
		 * in a specific <code>IMassLoader</code>. The file may be removed before the
		 * event is dispatched. If the index is not known, this property is -1.
		 * <p>Note that this value is linked to each <code>IMassLoader</code> and a file
		 * will probably have a different index depending on which <code>IMassLoader</code>
		 * it is loaded.</p>
		 */
		public function get index():int { return _index; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>MassLoadEvent</code> object.
		 * 
		 * @param	type		The type.
		 * @param	file		The file being loaded.
		 * @param	closeEvent	The <code>Event</code> dispatched to close the file. This event is cloned before beeing stored.
		 * @param	index		The index of the file into the loading queue.
		 */
		public function MassLoadEvent(type:String, file:ILoadManager=null, closeEvent:Event=null, index:int=-1):void
		{
			super(type, false, false);
			
			_file = file;
			_closeEvent = (closeEvent==null) ? null : closeEvent.clone();
			_index = index;
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