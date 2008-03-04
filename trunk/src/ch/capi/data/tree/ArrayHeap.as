package ch.capi.data.tree 
{	import ch.capi.data.tree.IHeap;
	
	/**
	 * Default implementation of a <code>IHeap</code>.
	 * 	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ArrayHeap implements IHeap
	{
		//---------//
		//Variables//
		//---------//
		private var _nextElement:*				= null;
		private var _elements:Array				= new Array();
		private var _sortFunction:Function;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the sort function that will be used to sort
		 * the items. The sort function must take two parameters and
		 * return an int value comparing it.
		 * 
		 * @example
		 * <listing version="3.0">
		 * var f:Function = function(a:int, b:int):int
		 * {
		 * 		return b-a;
		 * }
		 * 
		 * var h:ArrayHeap = new ArrayHeap(f);
		 * h.add(5);
		 * h.add(4);
		 * h.add(6);
		 * h.add(2);
		 * while (!h.isEmpty()) trace(h.remove);
		 * </listing>
		 */
		public function get sortFunction():Function { return _sortFunction; }
		
		/**
		 * Defines the next element that will be removed
		 * from the data structure.
		 */
		public function get nextElement():* { return _nextElement; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ArrayHeap</code> object.
		 * 
		 * @param	sortFunction	The sort function.
		 */
		public function ArrayHeap(sortFunction:Function):void
		{
			_sortFunction = sortFunction;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Add an element to the data structure.
		 * 
		 * @param	element		The element to add.
		 */
		public function add(element:*):void
		{
			_elements.push(element);
			
			var currentIndex:uint = _elements.length-1;
			
			while (currentIndex > 0)
			{
				var p:uint = Math.floor(currentIndex/2);
				var a:int = _sortFunction(_elements[p], _elements[currentIndex]);
				
				if (a <= 0) break;
				
				_elements[currentIndex] = _elements[p];
				_elements[p] = element;
				currentIndex = p;
			}
			
			_nextElement = _elements[0];
		}
		
		/**
		 * Removes an element from the data structure.
		 * 
		 * @return	The element removed.
		 */
		public function remove():*
		{
			if (isEmpty()) return null;
			
			var tr:* = _elements[0];
			
			//remove the last elements
			_elements[0] = _elements[_elements.length-1];
			_elements.splice(_elements.length-1, 1);
			
			var currentIndex:uint = 0;
			while(true)
			{
				var p1:uint = currentIndex*2;
				var p2:uint = p1+1;
				
				if (p1 > _elements.length-1) break;
				if (p2 <= _elements.length-1)
				{
					var c:int = _sortFunction(_elements[p1], _elements[p2]);
					if (c > 0) p1 = p2;
				}
				
				var d:int = _sortFunction(_elements[currentIndex], _elements[p1]);
				if (d <= 0) break;
				
				var temp:* = _elements[currentIndex];
				_elements[currentIndex] = _elements[p1];
				_elements[p1] = temp;
				currentIndex = p1;
			}
			
			_nextElement = _elements[0];
			
			return tr;
		}
		
		/**
		 * Removes all the elements from the data structure.
		 */
		public function clear():void
		{
			_elements = new Array();
		}
		
		/**
		 * Get if the structure is empty or not.
		 * 
		 * @return <code>true</code> if there is no element into
		 * 		   the structure.
		 */
		public function isEmpty():Boolean
		{
			return _elements.length == 0;
		}
		
		/**
		 * Retrieves the depth of the <code>Heap</code>.
		 * 
		 * @return	The depth.
		 */
		public function getDepth():uint
		{
			var c:uint = 0;
			var l:uint = _elements.length;
			while (l >= 1)
			{
				l = Math.floor(l/2);
				c++;
			}
			
			return c;
		}
		
		/**
		 * Retrieves if the specified element is contained into the <code>ArrayHeap</code>.
		 * 
		 * @param	element		The element.
		 * @return	<code>true</code> if the element is contained into the <code>ArrayHeap</code>.
		 */
		public function contains(element:*):Boolean
		{
			return getElementIndex(element) != -1;
		}
		
		/**
		 * Retrieves the depth of an alement. If the specified element is not into the
		 * <code>ArrayHeap</code>, then <code>-1</code> is returned.
		 * 
		 * @param		element		The element.
		 * @return		The element depth or <code>-1</code>.
		 */
		public function getElementDepth(element:*):int
		{
			var d:int = getElementIndex(element);
			if (d == -1) return -1;
			
			var c:uint = 0;
			while (d >= 1)
			{
				d = Math.floor(d/2);
				c++;
			}
			
			return c;
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
		private function getElementIndex(element:*):int
		{
			var b:uint = _elements.length;
			for (var i:uint=0 ; i<b ; i++)
			{
				if (_elements[i] == element) return i;
			}
			
			return -1;
		}	}}