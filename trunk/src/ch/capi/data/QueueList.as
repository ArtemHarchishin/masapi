package ch.capi.data
{
	/**
	 * Represents a basic implementation of a <code>IQueue</code> object.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class QueueList extends ArrayList implements IQueue
	{
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the next element that will be removed
		 * from the data structure.
		 */
		public function get nextElement():*
		{
			return (length==0) ? null : getElementAt(0);
		}
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>QueueList</code> object.
		 * 
		 * @param	initialData		The <code>Array</code> with the elements to initialize. All the elements
		 * 							contained in the <code>Array</code> will be added in the <code>QueueList</code>.
		 */
		public function QueueList(initialData:Array=null):void
		{
			super(initialData);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Get the first element of the <code>QueueList</code>.
		 * 
		 * @return	The first element.
		 */
		public function getFirstElement():*
		{
			return getElementAt(0);
		}
		
		/**
		 * Get the last element of the <code>QueueList</code>.
		 * 
		 * @return	The last element.
		 */
		public function getLastElement():*
		{
			return getElementAt(length-1);
		}
		
		/**
		 * Add an element to the data structure.
		 * 
		 * @param	element		The element to add.
		 */
		public function add(element:*):void
		{
			addElement(element);
		}
		
		/**
		 * Removes the first element of the <code>QueueList</code>.
		 * 
		 * @return	The element removed.
		 */
		public function remove():*
		{
			return (length==0) ? null : removeElementAt(0);
		}
	}
}