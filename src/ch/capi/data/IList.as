package ch.capi.data
{
	/**
	 * Represents a list of data.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface IList
	{
		/**
		 * Defines the number of elements contained into 
		 * the <code>IList</code>.
		 */
		function get length():uint;
		
		/**
		 * Add an element into the <code>IList</code>.
		 * 
		 * @param	element		The element to add.
		 */
		function addElement(element:*):void;
		
		/**
		 * Add an element into the <code>IList</code> at the specified index.
		 * 
		 * @param	element		The element to add.
		 * @param	index		The index of the element.
		 */
		function addElementAt(element:*, index:uint):void;
		
		/**
		 * Removes an element from the <code>IList</code>.
		 * 
		 * @param	element		The element to remove.
		 */
		function removeElement(element:*):void;
		
		/**
		 * Removes the element at the specified index from the <code>IList</code>.
		 * 
		 * @param	index		The index of the element to remove.
		 * @return	The removed element.
		 */
		function removeElementAt(index:uint):*;
		
		/**
		 * Removes all the elements contained into this <code>IList</code>.
		 */
		function clear():void;
		
		/**
		 * Get the element at the specified index.
		 * 
		 * @param	index		The index of the element to get.
		 * @return	The element at the specified index.
		 */
		function getElementAt(index:uint):*;
		
		/**
		 * Get the index of the specified element.
		 * 
		 * @param	element		The element to find.
		 * @return	The index of the element or -1 if the element is
		 * 			not found.
		 */
		function getElementIndex(element:*):int;
		
		/**
		 * Retrieves an <code>Array</code> from the <code>IList</code>.
		 * 
		 * @return	An <code>Array</code> containing the objects.
		 */
		function toArray():Array;
	}
}