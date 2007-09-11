package ch.capi.data
{
	/**
	 * Represents an object that maps keys to values.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface IMap
	{
		/**
		 * Removes all of the mappings from this map.
		 */
		function clear():void;
		
		/**
		 * Returns <code>true</code> if this map contains a mapping for the specified key.
		 * 
		 * @param		key		The key.
		 * @return		<code>true</code> if the specified key is contained into the <code>IMap</code>.
		 */
		function containsKey(key:*):Boolean;
		
		/**
		 * Returns true if this map maps one or more keys to the specified value.
		 * 
		 * @param	value		The value.
		 * @return	<code>true</code> if the specified value is contained into the <code>IMap</code>.
		 */
		function containsValue(value:*):Boolean;
		
		/**
		 * Retrieves the value mapped to the specified key or <code>null</code> if there is no mapping for
		 * the key.
		 * 
		 * @param	key		The key.
		 * @return	The object mapped to the specified key or <code>null</code>.
		 */
		function getValue(key:*):*;
		
		/**
		 * Returns true if the <code>IMap</code> contains no key-value mappings.
		 * 
		 * @return	<code>true</code> if there is no mapping.
		 */
		function isEmpty():Boolean;
		
		/**
		 * Associates the specified value with the specified key in the <code>IMap</code>.
		 * 
		 * @param	key		The key.
		 * @param	value	The value.
		 * @return	The previous value mapped to the key or <code>null</code>.
		 */
		function put(key:*, value:*):*;
		
		/**
		 * Retrieves all the key/value from the source <code>IMap</code> and put them
		 * in the current <code>IMap</code>.
		 * 
		 * @param	source		The source <code>IMap</code>. 
		 */
		function putAll(source:IMap):void;
		
		/**
		 * Removes the mapping for a key from the <code>IMap</code> if it is present.
		 * 
		 * @param	key		The key to remove.
		 * @return	The mapped value for this key.
		 */
		function remove(key:*):*;
		
		/**
		 * Retrieves the number of key-value mappings into the <code>IMap</code>.
		 * 
		 * @return	The number of key-value mappings.
		 */
		function size():uint;
		
		/**
		 * Retrieves all the values contained into the <code>IMap</code>.
		 * 
		 * @return	An <code>Array</code> containing all the values.
		 */
		function values():Array;
		
		/**
		 * Retrieves all the keys contained into the <code>IMap</code>.
		 * 
		 * @return	An <code>Array</code> containing all the keys.
		 */
		function keys():Array;
	}
}