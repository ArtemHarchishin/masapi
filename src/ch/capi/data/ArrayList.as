package ch.capi.data
{
	/**
	 * Represents a <code>IList</code> using an <code>Array</code>
	 * to store the elements.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class ArrayList implements IList
	{
		//---------//
		//Variables//
		//---------//
		private var _data:Array			= new Array();
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the number of elements contained into 
		 * the <code>ArrayList</code>.
		 */
		public function get length():uint { return _data.length; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ArrayList</code> object.
		 * 
		 * @param	initialData		The initial data to add to the <code>ArrayList</code>.
		 */
		public function ArrayList(initialData:Array = null):void
		{
			if (initialData != null) _data.push.apply(_data, initialData);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add an element into the <code>ArrayList</code>.
		 * 
		 * @param	element		The element to add.
		 */
		public function addElement(element:*):void
		{
			_data.push(element);
		}
		
		/**
		 * Add an element into the <code>ArrayList</code> at the specified index.
		 * 
		 * @param	element		The element to add.
		 * @param	index		The index of the element.
		 */
		public function addElementAt(element:*, index:uint):void
		{
			checkIndex(index, _data.length);
			_data.splice(index, 0, element);
		}
		
		/**
		 * Removes an element from the <code>ArrayList</code>.
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
		 * Removes the element at the specified index from the <code>ArrayList</code>.
		 * 
		 * @param	index		The index of the element to remove.
		 * @return	The removed element.
		 */
		public function removeElementAt(index:uint):*
		{
			checkIndex(index, _data.length-1);
			_data.splice(index, 1);
			return _data[index];
		}
		
		/**
		 * Removes all the elements contained into this <code>ArrayList</code>.
		 */
		public function clear():void
		{
			_data = [];
		}
		
		/**
		 * Get the element at the specified index.
		 * 
		 * @param	index		The index of the element to get.
		 * @return	The element at the specified index.
		 */
		public function getElementAt(index:uint):*
		{
			checkIndex(index, _data.length-1);
			return _data[index];
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
			var l:uint = _data.length;
			for (var i:uint=0 ; i<l ; i++)
			{
				if (_data[i] == element) return i;
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
			return length == 0;
		}
		
		/**
		 * Displays the <code>ArrayList</code> into a <code>String</code>.
		 * 
		 * @return	A <code>String</code> representing the <code>ArrayList</code>.
		 */
		public function toString():String
		{
			var s:String = "ArrayList("+length+")[";
			var l:int = _data.length-1;
			if (l >= 0)
			{
				for (var i:uint=0 ; i<l ; i++)
				{
					s += _data[i]+", ";
				}
				s += _data[l];
			}
			s += "]";
			
			return s;
		}
		
		/**
		 * Retrieves an <code>Array</code> from the <code>ArrayList</code>.
		 * 
		 * @return	An <code>Array</code> containing the objects.
		 */
		public function toArray():Array
		{
			return _data.concat();
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		
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