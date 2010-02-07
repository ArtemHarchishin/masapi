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
		 * Defines the number of elements contained in
		 * the <code>IList</code>.
		 */
		function get length():int;
		
		/**
		 * Add an element in the <code>IList</code>.
		 * 
		 * @param	element		The element to add.
		 */
		function addElement(element:*):void;
		
		/**
		 * Add an element in the <code>IList</code> at the specified index.
		 * 
		 * @param	element		The element to add.
		 * @param	index		The index of the element.
		 */
		function addElementAt(element:*, index:int):void;
		
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
		function removeElementAt(index:int):*;
		
		/**
		 * Removes all the elements contained in this <code>IList</code>.
		 */
		function clear():void;
		
		/**
		 * Get the element at the specified index.
		 * 
		 * @param	index		The index of the element to get.
		 * @return	The element at the specified index.
		 */
		function getElementAt(index:int):*;
		
		/**
		 * Get the index of the specified element.
		 * 
		 * @param	element		The element to find.
		 * @return	The index of the element or -1 if the element is
		 * 			not found.
		 */
		function getElementIndex(element:*):int;
		
		/**
		 * Returns <code>true</code> if the specified element is contained in the <code>IList</code>
		 * or <code>false</code> otherwise.
		 * <p>The comparison function must take two arguments that are issued from the <code>IList</code>
		 * and must return a <code>Boolean</code> indicating whetever the two elements are the same or not.</p>
		 * 
		 * @param	element		The element to find.
		 * @param 	compare		The comparison function. If <code>null</code>, then the strict equality operator 
		 * 						(<code>===</code>) will be used.
		 * @return	<code>true</code> if the element is in the <code>IList</code>.
		 * @see		#getElementIndex()	getElementIndex()
		 * 
		 * @example
		 * <listing version="3.0">
		 * var cmp:Function = function(a:Object, b:Object):Boolean
		 * {
		 * 		return a.aProperty == b.aProperty;
		 * }
		 * var isContained:Boolean = myList.contains(myObject, cmp);
		 * </listing>
		 */
		function contains(element:*, compare:Function=null):Boolean;
		
		/**
		 * Retrieves an <code>Array</code> from the <code>IList</code>.
		 * 
		 * @return	An <code>Array</code> containing the objects.
		 */
		function toArray():Array;
	}
}