package ch.capi.data.tree 
{
	/**
	 * This class represents an element into the ArrayHeap.
	 * It is used by the <code>ArrayHeap</code> to store the its elements, but
	 * shouldn't be used outside this purpose...
	 * 
	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0
	 */
	internal class HeapElement
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
			_index = __sharedIndex++;
		}
		
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
}
