package ch.capi.events 
{
	
	/**
	 * Represents a priority event.
	 * 
	 * @version	1.0
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
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the current priority.
		 */
		public function get currentPriority():int { return _currentPriority; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>PriorityEvent</code> object.
		 * 
		 * @param	type		The type.
		 * @param	newPriority	The new priority.
		 */
		public function PriorityEvent(type:String, newPriority:int=0):void
		{
			super(type, false, false);
			
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
			return new PriorityEvent(type, _currentPriority);
		}