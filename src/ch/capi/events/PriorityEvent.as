package ch.capi.events 
{	import flash.events.Event;
	
	/**
	 * Represents a priority event.
	 * 	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class PriorityEvent extends Event
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Event when the priority changes.
		 */
		public static const PRIORITY_CHANGED:String = "priorityChanged";
		
		//---------//
		//Variables//
		//---------//
		private var _currentPriority:int;
		private var _files:Array;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the current priority.
		 */
		public function get currentPriority():int { return _currentPriority; }
		
		/**
		 * Defines the file to load at the current priority.
		 */
		public function get files():Array { return _files; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>PriorityEvent</code> object.
		 * 
		 * @param	type		The type.
		 * @param	newPriority	The new priority.
		 * @param	files		The files to load.
		 */
		public function PriorityEvent(type:String, newPriority:int=0, files:Array=null):void
		{
			super(type, false, false);
			
			_files = files;
			_currentPriority = newPriority;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Creates a copy of the <code>PriorityEvent</code> object and sets the value of each property to match that of the original.
		 * 
		 * @return	The cloned <code>Event</code>.
		 */
		public override function clone():Event
		{
			return new PriorityEvent(type, _currentPriority, _files);
		}	}}