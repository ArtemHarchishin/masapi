package ch.capi.data
{
	/**
	 * Represents a <code>IList</code> where elements are
	 * linked using the <code>IListElement</code> object.
	 * 
	 * @see			ch.capi.data.IListElement		IListElement
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class LinkedList implements IList
	{
		//---------//
		//Variables//
		//---------//
		private var _firstElement:IListElement		= null;
		private var _lastElement:IListElement		= null;
		private var _length:uint					= 0;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the number of elements contained into 
		 * the <code>LinkedList</code>.
		 */
		public function get length():uint { return _length; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>LinkedList</code> object.
		 * 
		 * @param	initialData		The <code>Array</code> with the elements to initialize. All the elements
		 * 							contained into the <code>Array</code> will be added into the <code>LinkedList</code>.
		 */
		public function LinkedList(initialData:Array=null):void
		{
			if (initialData != null)
			{
				var l:uint = initialData.length;
				for (var i:uint=0 ; i<l ; i++)
				{
					addElement(initialData[i]);
				}
			}
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add an element into the <code>LinkedList</code>.
		 * 
		 * @param	element		The element to add.
		 */
		public function addElement(element:*):void
		{
			addElementAt(element, _length);
		}
		
		/**
		 * Add an element into the <code>LinkedList</code> at the specified index.
		 * 
		 * @param	element		The element to add.
		 * @param	index		The index of the element.
		 */
		public function addElementAt(element:*, index:uint):void
		{
			var e:IListElement = createListElement(element);
			var p:IListElement = getListElementAt(index);

			if (index == 0) _firstElement = e;
			if (p == null)
			{
				if (_lastElement != null)
				{
					e.previousElement = _lastElement;
					_lastElement.nextElement = e;					
				}
				
				_lastElement = e;
			}
			else
			{
				e.nextElement = p;
				e.previousElement = p.previousElement;
				p.previousElement = e;
				
				if (e.previousElement != null)
				{
					e.previousElement.nextElement = e;
				}
			}
			
			_length++;
		}
		
		/**
		 * Removes an element from the <code>LinkedList</code>.
		 * 
		 * @param	element		The element to remove.
		 */
		public function removeElement(element:*):void
		{
			var index:int = getElementIndex(element);
			if (index == -1) return;
			
			removeElementAt(index);
		}
		
		/**
		 * Removes the element at the specified index from the <code>LinkedList</code>.
		 * 
		 * @param	index		The index of the element to remove.
		 * @return	The removed element.
		 */
		public function removeElementAt(index:uint):*
		{
			checkIndex(index, _length-1);
			
			var e:IListElement = getListElementAt(index);
			var p:IListElement = e.previousElement;
			var n:IListElement = e.nextElement;
			
			if (p != null) p.nextElement = n;
			if (n != null) n.previousElement = p;
			if (index == 0) _firstElement = n;
			if (index == _length-1) _lastElement = p;
			
			_length--;
			
			return e.data;
		}
		
		/**
		 * Removes all the elements contained into this <code>LinkedList</code>.
		 */
		public function clear():void
		{
			_length = 0;
			_firstElement = null;
			_lastElement = null;
		}
		
		/**
		 * Get the element at the specified index.
		 * 
		 * @param	index		The index of the element to get.
		 * @return	The element at the specified index.
		 */
		public function getElementAt(index:uint):*
		{
			checkIndex(index, _length-1);
			var e:IListElement = getListElementAt(index);
			return e.data;
		}
		
		/**
		 * Get the index of the specified element.
		 * 
		 * @param	element		The element to find.
		 * @return	The index of the element or -1 if the element is
		 * 			not found.
		 */
		public function getElementIndex(element:*):int
		{
			var current:IListElement = _firstElement;
			for (var i:uint=0 ; i<_length ; i++)
			{
				if (current.data == element) return i;
				current = current.nextElement;
			}
			
			return -1;
		}
		
		/**
		 * Get if the structure is empty or not.
		 * 
		 * @return <code>true</code> if there is no element into
		 * 		   the structure.
		 */
		public function isEmpty():Boolean
		{
			return _length == 0;
		}
		
		/**
		 * Displays the <code>LinkedList</code> into a <code>String</code>.
		 * 
		 * @return	A <code>String</code> representing the <code>LinkedList</code>.
		 */
		public function toString():String
		{
			var s:String = "LinkedList("+length+")[";
			var l:int = _length-1;
			if (l > 0)
			{
				var current:IListElement = _firstElement;
				for (var i:uint=0 ; i<l ; i++)
				{
					s += current.data+", ";
					current = current.nextElement;	
				}
				s += current.data;
			}
			s += "]";
			
			return s;
		}
		
		/**
		 * Retrieves an <code>Array</code> from the <code>LinkedList</code>.
		 * 
		 * @return	An <code>Array</code> containing the objects.
		 */
		public function toArray():Array
		{
			var a:Array = new Array();
			var c:IListElement = _firstElement;
			
			while (c != null)
			{
				a.push(c.data);
				c = c.nextElement;
			}
			
			return a;
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Creates a <code>BasicListElement</code> from an element.
		 * 
		 * @param	element		The element.
		 * @return	A <code>IListElement</code> object.
		 * @see		ch.capi.data.BasicListElement	BasicListElement
		 */
		protected function createListElement(element:*):IListElement
		{
			return new BasicListElement(element);
		}
		
		/**
		 * Get the first <code>IListElement</code> of the <code>LinkedList</code>.
		 * 
		 * @return	The first <code>IListElement</code>.
		 */
		protected function getFirstListElement():IListElement
		{
			return _firstElement;
		}
		
		/**
		 * Get the last <code>IListElement</code> of the <code>LinkedList</code>.
		 * 
		 * @return	The last <code>IListElement</code>.
		 */
		protected function getLastListElement():IListElement
		{
			return _lastElement;
		}
		
		/**
		 * Retrieves the <code>IListElement</code> at the specified index.
		 * 
		 * @param	index	The index.
		 * @return	The <code>IListElement</code> or <code>null</code>.
		 */
		protected function getListElementAt(index:uint):IListElement
		{
			var current:IListElement;
			
			if (index == _length) return null;
			if (index < _length/2)
			{
				current = _firstElement;
				while (index-- > 0)
				{
					current = current.nextElement;
				}
			}
			else
			{
				current = _lastElement;
				index = _length-index;
				while (index-- > 1)
				{
					current = current.previousElement;
				}
			}
			
			return current;
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function checkIndex(index:uint, max:uint):void
		{
			if (index > max)
			{
				throw new RangeError("Invalid index value : "+index+" (max = "+max+")");
			}
		}
	}
}