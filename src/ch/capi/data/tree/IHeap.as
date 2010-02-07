package ch.capi.data.tree 
{	import ch.capi.data.IDataStructure;
	
	/**
	 * Represents a heap data structure.
	 * 	 * @author	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public interface IHeap extends IDataStructure
	{
		/**
		 * Defines the sort function that will be used to sort
		 * the items.
		 */
		function get sortFunction():Function;
		
		/**
		 * Retrieves if the specified element is contained in
		 * the <code>IHeap</code>.
		 * 
		 * @param	element		The element.
		 * @return	<code>true</code> if the element is contained in the <code>IHeap</code>.
		 */
		function contains(element:*):Boolean;	}}