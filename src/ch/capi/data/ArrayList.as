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
		 * Defines the number of elements contained in
		 * the <code>ArrayList</code>.
		 */
		public function get length():int { return _data.length; }
		
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
		 * Add an element in the <code>ArrayList</code>.
		 * 
		 * @param	element		The element to add.
		 */
		public function addElement(element:*):void
		{
			_data.push(element);
		}
		
		/**
		 * Add an element in the <code>ArrayList</code> at the specified index.
		 * 
		 * @param	element		The element to add.
		 * @param	index		The index of the element.
		 */
		public function addElementAt(element:*, index:int):void
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
		public function removeElementAt(index:int):*
		{
			checkIndex(index, _data.length-1);
			var removed:* = _data[index];
			
			_data.splice(index, 1);
			
			return removed;
		}
		
		/**
		 * Removes all the elements contained in this <code>ArrayList</code>.
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
		public function getElementAt(index:int):*
		{
			checkIndex(index, _data.length-1);
			return _data[index];
		}
		
		/**
		 * Get the index of the specified element. The comparison operator is the strict
		 * equality (<code>===</code>).
		 * 
		 * @param	element		The element to find.
		 * @return	The index of the element or -1 if the element is
		 * 			not found.
		 */
		public function getElementIndex(element:*):int
		{ 
			return _data.indexOf(element);
		}
		
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
		 * 		// a will always be the element passed to the contains method
		 * 		return a.aProperty == b.aProperty;
		 * }
		 * var isContained:Boolean = myList.contains(myObject, cmp);
		 * </listing>
		 */
		public function contains(element:*, compare:Function=null):Boolean
		{
			var test:Function;
			if (compare == null) test = function(obj:*, i:int, a:Array):Boolean { return obj === element; };
			else test = function(obj:*, i:int, a:Array):Boolean { return compare(element, obj); };
			
			return _data.some(test, null); //as test is a closure, thisObject must be null	
		}
		
		/**
		 * Get if the structure is empty or not.
		 * 
		 * @return <code>true</code> if there is no element in
		 * 		   the structure.
		 */
		public function isEmpty():Boolean
		{
			return length == 0;
		}
		
		/**
		 * Displays the <code>ArrayList</code> in a <code>String</code>.
		 * 
		 * @return	A <code>String</code> representing the <code>ArrayList</code>.
		 */
		public function toString():String
		{
			var s:String = "ArrayList("+length+")[";
			var l:int = _data.length-1;
			if (l >= 0)
			{
				for (var i:int=0 ; i<l ; i++)
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
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function checkIndex(index:int, max:int):void
		{
			if (index > max || index < 0)
			{
				throw new RangeError("Invalid index value : "+index+" (max = "+max+")");
			}
		}
	}
}