package ch.capi.data.tree 
{
	
	/**
	 * Represents a heap data structure.
	 * 
	 * @version	1.0
	{
		/**
		 * Defines the sort function that will be used to sort
		 * the items.
		 */
		function get sortFunction():Function;
		
		/**
		 * Retrieves if the specified element is contained into
		 * the <code>IHeap</code>.
		 * 
		 * @param	element		The element.
		 * @return	<code>true</code> if the element is contained into the <code>IHeap</code>.
		 */
		function contains(element:*):Boolean;