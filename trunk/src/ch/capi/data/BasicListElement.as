package ch.capi.data
{
	/**
	 * Represents a basic implementation of a <code>IListElement</code>.
	 * 
	 * @see			ch.capi.data.IList		IList
	 * @see			ch.capi.data.LinkedList	LinkedList
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class BasicListElement implements IListElement
	{
		//---------//
		//Variables//
		//---------//
		private var _data:*;
		private var _nextElement:IListElement			= null;
		private var _previousElement:IListElement		= null;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the data of the <code>BasicListElement</code>.
		 */
		public function get data():* { return _data; }
		public function set data(value:*):void { _data = value; }
		
		/**
		 * Defines the next linked element.
		 */
		public function get nextElement():IListElement { return _nextElement; }
		public function set nextElement(value:IListElement):void { _nextElement = value; }
		
		/**
		 * Defines the previous linked element.
		 */
		public function get previousElement():IListElement { return _previousElement; }
		public function set previousElement(value:IListElement):void { _previousElement = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>BasicListElement</code> object.
		 * 
		 * @param	data	The data of the <code>BasicListElement</code> object.
		 */
		public function BasicListElement(data:* = null):void
		{
			_data = data;
		}
	}
}