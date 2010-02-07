package ch.capi.events
{
	import ch.capi.net.ILoadableFile;	
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
		
		/**
		 * Event when the loading of a file progresses.
		 */
		public static const FILE_PROGRESS:String = "fileProgress";
		
		//---------//
		//Variables//
		//---------//
		private var _file:ILoadManager;
		private var _closeEvent:Event;
		private var _staticIndex:int;
		private var _queueIndex:int;
		private var _loadedIndex:int;
		private var _priority:int;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>ILoadManager</code> being loaded.
		 * 
		 * @see		#getFile()	getFile()
		 */
		public function get loadManager():ILoadManager { return _file; }

		/**
		 * Defines the event that occured when the file was closed.
		 */
		public function get closeEvent():Event { return _closeEvent; }
		
		/**
		 * Defines the index of the file in the loading queue.
		 * 
		 * @see	ch.capi.net.MassLoader#getFileQueueIndex()	MassLoader.getFileQueueIndex()
		 */
		public function get queueIndex():int { return _queueIndex; }
		
		/**
		 * Defines the index of the file in the loaded queue. It indicates how many files
		 * have been loaded before the <code>loadManager</code>.
		 */
		public function get loadedIndex():int { return _loadedIndex; }
		
		/**
		 * Defines the index of the file. The index is unique for a <code>ILoadableFile</code>
		 * in a specific <code>IMassLoader</code>. The file may be removed before the
		 * event is dispatched. If the index is not known, this property is -1.
		 * 
		 * @see	ch.capi.net.MassLoader#getFileStaticIndex()	MassLoader.getFileStaticIndex()
		 */
		public function get staticIndex():int { return _staticIndex; }
		public function set staticIndex(value:int):void { _staticIndex = value; }
		
		/**
		 * The priority of the file. If the file wasn't loaded in a <code>PriorityMassLoader</code> 
		 * this value will be 0.
		 */
		public function get priority():int { return _priority; }
		public function set priority(value:int):void { _priority = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>MassLoadEvent</code> object.
		 * 
		 * @param	type			The type.
		 * @param	file			The file being loaded.
		 * @param	closeEvent		The <code>Event</code> dispatched to close the file. This event is cloned before beeing stored.
		 * @param	staticIndex		The static index of the file in the loading queue.
		 * @param	queueIndex		The index of the file in the loading queue.
		 * @param	loadedIndex		The index of the file in the loaded queue.
		 * @param	priority		The file priority.
		 */
		public function MassLoadEvent(type:String, file:ILoadManager=null, closeEvent:Event=null, staticIndex:int=-1, queueIndex:int=-1, loadedIndex:int=-1, priority:int=0):void
		{
			super(type, false, false);
			
			_file = file;
			_closeEvent = (closeEvent==null) ? null : closeEvent.clone();
			_staticIndex = staticIndex;
			_queueIndex = queueIndex;
			_loadedIndex = loadedIndex;
			_priority = priority;
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
			return new MassLoadEvent(type, _file, _closeEvent, _staticIndex, _queueIndex, _loadedIndex, _priority);
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
		
		/**
		 * Checks if the contained <code>ILoadManager</code> is a <code>ILoadableFile</code>.
		 * 
		 * @return	<code>true</code> if the <code>ILoadManager</code> is a <code>ILoadableFile</code>.
		 */
		public function isLoadableFile():Boolean
		{
			return _file is ILoadableFile;
		}
		
		/**
		 * Retrieves the <code>ILoadManager</code> as <code>ILoadableFile</code>.
		 * 
		 * @return	The <code>ILoadManager</code> as <code>ILoadableFile</code>.
		 * @throws	Error	If the <code>ILoadManager</code> is not a <code>ILoadableFile</code>.
		 * @see		#isLoadableFile()	isLoadableFile()
		 */
		public function getFile():ILoadableFile
		{
			if (!isLoadableFile()) throw new Error("Cast exception : the loadManger is not a ILoadbleFile");
			return _file as ILoadableFile;
		}
		
		/**
		 * Returns the <code>MassLoadEvent</code> in a <code>String</code>.
		 * 
		 * @return	A <code>String</code> containing the <code>MassLoadEvent</code> properties values.
		 */
		public override function toString():String
		{
			return "MassLoadEvent["+
				"\n type : "+type+
				"\n file : "+loadManager+
				"\n closeEvent : "+closeEvent+
				"\n priority : "+priority+
				"\n queueIndex : "+queueIndex+
				"\n staticIndex : "+staticIndex+
				"\n loadedIndex : "+loadedIndex
				+"\n]";
		}
	}
}