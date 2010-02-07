package ch.capi.data
{
	/**
	 * Represents a basic implementation of a <code>IStack</code> object.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class StackList extends ArrayList implements IStack
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
		 * Creates a new <code>StackList</code> object.
		 * 
		 * @param	initialData		The <code>Array</code> with the elements to initialize. All the elements
		 * 							contained in the <code>Array</code> will be added in the <code>StackList</code>.
		 */
		public function StackList(initialData:Array=null):void
		{
			super(initialData);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Get the top element of the <code>StackList</code>.
		 * 
		 * @return	The top element.
		 */
		public function getTopElement():*
		{
			return getElementAt(0);
		}
		
		/**
		 * Add an element to the data structure.
		 * 
		 * @param	element		The element to add.
		 */
		public function add(element:*):void
		{
			addElementAt(element, 0);
		}
		
		/**
		 * Removes the last element of the <code>StackList</code>.
		 * 
		 * @return	The element removed.
		 */
		public function remove():*
		{
			return (length==0) ? null : removeElementAt(0);
		}
	}
}