package ch.capi.data
{
	/**
	 * Represents an element to be used by
	 * a <code>IList</code> to store data.
	 * 
	 * @see			ch.capi.data.IList		IList
	 * @see			ch.capi.data.LinkedList LinkedList
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface IListElement
	{
		/**
		 * Defines the data of the <code>IListElement</code>.
		 */
		function get data():*;
		function set data(value:*):void;
		
		/**
		 * Defines the next linked element.
		 */
		function get nextElement():IListElement;
		function set nextElement(value:IListElement):void;
		
		/**
		 * Defines the previous linked element.
		 */
		function get previousElement():IListElement;
		function set previousElement(value:IListElement):void;
	}
}