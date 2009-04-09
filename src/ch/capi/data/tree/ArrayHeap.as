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
		private var _nextElement:HeapElement	= null;
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
		public function get nextElement():* { return (_nextElement==null)?null:_nextElement.element; }

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
			var heapElement:HeapElement = new HeapElement(element);
			_elements.push(heapElement);
			
			var currentIndex:uint = _elements.length-1;
			
			while (currentIndex > 0)
			{
				var p:uint = Math.floor(currentIndex/2);
				var a:int = _sortFunction(_elements[p].element, _elements[currentIndex].element);
				
				if (a <= 0) break;
				
				_elements[currentIndex] = _elements[p];
				_elements[p] = heapElement;
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
			
			var tr:HeapElement = _elements[0];
			
			//remove the last element and put it on the top of the heap
			_elements[0] = _elements[_elements.length-1];
			_elements.splice(_elements.length-1, 1);
			
			var currentIndex:uint = 0;
			while(true)
			{
				//calculates the indexes
				var p1:uint = currentIndex*2;
				var p2:uint = p1+1;
				
				//if the p1 index is out of bounds => exit
				if (p1 > _elements.length-1) break;
				
				//if the p2 index is into the bounds, compare the children and take the
				//bigger one
				if (p2 <= _elements.length-1)
				{
					var leftElement:HeapElement = _elements[p1];
					var rightElement:HeapElement = _elements[p2];
					
					var c:int = _sortFunction(leftElement.element, rightElement.element);
				
					//the right element is bigger or both elements are 
					//equal each other => take the one that has the lower index
					//so the adding order will be kept
					if (c > 0 || (c == 0 && rightElement.index < leftElement.index))
					{
						p1 = p2; 
					}
				}
				
				var parentElement:HeapElement = _elements[currentIndex];
				var childElement:HeapElement = _elements[p1];
				
				//compare the parent and the biggest of the children
				var d:int = _sortFunction(parentElement.element, childElement.element);
				
				//if the child is lower than the parent, and the index of the parent
				//is lower than the child, exit
				if (d < 0 || (d == 0 && parentElement.index <= childElement.index)) break;
				
				//the child and the parents must be inverted
				var temp:* = _elements[currentIndex];
				_elements[currentIndex] = _elements[p1];
				_elements[p1] = temp;
				currentIndex = p1;
			}
			
			_nextElement = _elements[0];
			
			//if there is no more element into the heap, the index can
			//be reset to zero
			if (_elements.length == 0) HeapElement.resetSharedIndex();
			
			return tr.element;
		}
		
		/**
		 * Removes all the elements from the data structure.
		 */
		public function clear():void
		{
			_elements = new Array();
			_nextElement = null;
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
				if (_elements[i].element == element) return i;
			}
			
			return -1;
		}	}}

/**
 * This class represents an element into the ArrayHeap.
 */
class HeapElement
{
	//---------//
	//Variables//
	//---------//
	private static var __sharedIndex:int = 0;
	private var _index:int;
	private var _element:*;
	
	//-----------------//
	//Getters & Setters//
	//-----------------//
	
	/**
	 * Defines the element.
	 */
	public function get element():* { return _element; }
	
	/**
	 * Defines the index of the element.
	 */
	public function get index():int { return _index; }
	
	//-----------//
	//Constructor//
	//-----------//
	
	/**
	 * Creates a new <code>ArrayHeap</code> object.
	 * 
	 * @param	element		The heap element.
	 */
	public function HeapElement(element:*):void
	{
		_element = element;
		_index = __sharedIndex++;	}
	
	//--------------//
	//Public methods//
	//--------------//
	
	/**
	 * Resets the shared index. The index of the next inserted
	 * element will be zero.
	 */
	public static function resetSharedIndex():void
	{
		__sharedIndex = 0;
	}
}
