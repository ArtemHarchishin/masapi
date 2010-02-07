package ch.capi.data
{
	import flash.utils.Dictionary;
	
	/**
	 * Represents a <code>IMap</code> based on a <code>Dictionnary</code>.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class DictionnaryMap implements IMap
	{
		//---------//
		//Variables//
		//---------//
		private var _count:uint					= 0;
		private var _dictionnary:Dictionary;
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>DictionnaryMap</code> object.
		 * 
		 * @param	weakKeys		Instructs the Dictionary object to use "weak" references on object keys.
		 */
		public function DictionnaryMap(weakKeys:Boolean=false):void
		{
			_dictionnary = new Dictionary(weakKeys);
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Removes all of the mappings from this map.
		 */
		public function clear():void
		{
			for (var i:String in _dictionnary)
			{
				delete _dictionnary[i];
			}
			
			_count = 0;
		}
		
		/**
		 * Returns <code>true</code> if this map contains a mapping for the specified key.
		 * 
		 * @param		key		The key.
		 * @return		<code>true</code> if the specified key is contained into the <code>IMap</code>.
		 */
		public function containsKey(key:*):Boolean
		{
			return (key in _dictionnary);
		}
		
		/**
		 * Returns true if this map maps one or more keys to the specified value.
		 * 
		 * @param	value		The value.
		 * @return	<code>true</code> if the specified value is contained into the <code>IMap</code>.
		 */
		public function containsValue(value:*):Boolean
		{
			for each(var k:* in _dictionnary)
			{
				if (k == value) return true;
			}
						
			return false;
		}
		
		/**
		 * Retrieves the value mapped to the specified key or <code>null</code> if there is no mapping for
		 * the key.
		 * 
		 * @param	key		The key.
		 * @return	The object mapped to the specified key or <code>null</code>.
		 */
		public function getValue(key:*):*
		{
			return _dictionnary[key];
		}
		
		/**
		 * Returns true if the <code>IMap</code> contains no key-value mappings.
		 * 
		 * @return	<code>true</code> if there is no mapping.
		 */
		public function isEmpty():Boolean
		{
			return _count == 0;
		}
		
		/**
		 * Associates the specified value with the specified key in the <code>IMap</code>.
		 * 
		 * @param	key		The key.
		 * @param	value	The value.
		 * @return	The previous value mapped to the key or <code>null</code>.
		 * @throws	Error	If the key is <code>null</code>.
		 */
		public function put(key:*, value:*):*
		{
			if (key == null) throw new Error("The key is not defined (value="+value+")");
			
			var old:* = _dictionnary[key];
			_dictionnary[key] = value;
			
			if (old == null) _count++;
			
			return old;
		}
		
		/**
		 * Retrieves all the key/value from the source <code>IMap</code> and put them
		 * in the current <code>IMap</code>.
		 * 
		 * @param	source		The source <code>IMap</code>. 
		 */
		public function putAll(source:IMap):void
		{
			var keys:Array = source.keys();
			for each(var currentKey:* in keys)
			{
				var currentValue:* = source.getValue(currentKey);
				put(currentKey, currentValue);	
			}
		}
		
		/**
		 * Puts all the key/value from the specified object into the <code>IMap</code>.
		 * 
		 * @param	obj		The source <code>Object</code>.
		 */
		public function putObject(obj:Object):void
		{
			for (var key:String in obj)
			{
				put(key, obj[key]);
			}
		}
		
		/**
		 * Removes the mapping for a key from the <code>IMap</code> if it is present.
		 * 
		 * @param	key		The key to remove.
		 * @return	The mapped value for this key.
		 */
		public function remove(key:*):*
		{
			var old:* = _dictionnary[key];
			
			delete _dictionnary[key];
			_count--;
			
			return old;
		}
		
		/**
		 * Retrieves the number of key-value mappings into the <code>IMap</code>.
		 * 
		 * @return	The number of key-value mappings.
		 */
		public function size():uint
		{
			return _count;
		}
		
		/**
		 * Retrieves all the values contained into the <code>IMap</code>.
		 * 
		 * @return	An <code>Array</code> containing all the values.
		 */
		public function values():Array
		{
			var list:Array = new Array();
			for each(var value:* in _dictionnary)
			{
				list.push(value);
			}
			
			return list;
		}
		
		/**
		 * Retrieves all the keys contained into the <code>IMap</code>.
		 * 
		 * @return	An <code>Array</code> containing all the keys.
		 */
		public function keys():Array
		{
			var list:Array = new Array();
			for (var i:* in _dictionnary)
			{
				list.push(i);
			}
			return list;
		}
		
		/**
		 * Retrieves a <code>String</code> displaying all the key/value pairs of the <code>DictionnaryMap</code>.
		 * 
		 * @return	A <code>String</code> representing the <code>DictionnaryMap</code>.
		 */
		public function toString():String
		{
			var str:String = "";
			for (var key:* in _dictionnary)
			{
				str += key+ " => " + _dictionnary[key] + "\n";
			}
			
			return str;
		}
		
		/**
		 * Returns an <code>Object</code> from the <code>IMap</code>.
		 * 
		 * @return	An <code>Object</code> with the same pair key/values.
		 */
		public function toObject():Object
		{
			var obj:Object = new Object();
			
			for(var key:* in _dictionnary)
			{
				obj[key] = _dictionnary[key];
			}
			
			return obj;
		}
		
		/**
		 * Compares the <code>IMap</code> and the specified <code>Object</code> pairs
		 * key/value and checks if the values are the same. A <code>null Object</code>
		 * will be considered as an empty <code>Object</code>.
		 * 
		 * @param	obj		An <code>Object</code> to compare. If the <code>Object</code> is
		 * 					a <code>IMap</code>, then it will be used as it.
		 * @param	strict	Defines if the match must be strict or if there can be more pairs
		 * 					into the <code>IMap</code> than defined into the <code>Object</code>.
		 * @return	<code>true</code> if the <code>IMap</code> matches the <code>Object</code>.
		 */
		public function matches(obj:Object, strict:Boolean=false):Boolean
		{
			if (obj == null) obj = new Object();
			
			//special check if the object is an IMap
			if (obj is IMap)
			{
				var m:IMap = obj as IMap;
				
				//if the match is strict and the size are not the same, then
				//simply return false
				if (strict && this.size() != m.size()) return false;
				
				obj = m.toObject();	
			}
			
			/*
			 * Loops on each key of the object and checks the corresponding
			 * value into the map. If the key is not found, then directly
			 * returns false, otherwise checks the values.
			 */
			var counter:int = 0;
			for (var key:* in obj)
			{
				if (! (key in _dictionnary)) return false;
				
				var objValue:* = obj[key];
				var dicValue:* = _dictionnary[key];
				
				if (objValue != dicValue) return false;
				
				counter++;
			}
			
			/*
			 * Here means that all the pairs key/value into the IMap and Object
			 * matches. If the check is strict, the size must be the same otherwise
			 * simple return true.
			 */
			return (strict) ? (counter == size()) : true;
		}
	}
}
