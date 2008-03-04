package ch.capi.data
{
	/**
	 * Represents a data structure.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @vesrion		1.0
	 */
	public interface IDataStructure
	{
		/**
		 * Defines the next element that will be removed
		 * from the data structure.
		 */
		function get nextElement():*;
		
		/**
		 * Add an element to the data structure.
		 * 
		 * @param	element		The element to add.
		 */
		function add(element:*):void;
		
		/**
		 * Removes an element from the data structure.
		 * 
		 * @return	The element removed.
		 */
		function remove():*;
		
		/**
		 * Removes all the elements from the data structure.
		 */
		function clear():void;
		
		/**
		 * Get if the structure is empty or not.
		 * 
		 * @return <code>true</code> if there is no element into
		 * 		   the structure.
		 */
		function isEmpty():Boolean;
	}
}