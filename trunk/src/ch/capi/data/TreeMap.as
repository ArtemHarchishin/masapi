package ch.capi.data{	/**	 * A <code>TreeMap</code> is a simply structured <code>IMap</code>  that can have a parent	 * <code>IMap</code> to search some keys.	 * Note that the methods <code>remove()</code> and <code>clear()</code> won't affect the parent	 * <code>IMap</code>.	 * 	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public class TreeMap extends DictionnaryMap implements IMap	{		//---------//		//Constants//		//---------//				//---------//		//Variables//		//---------//		private var _parent:IMap;				//-----------------//		//Getters & Setters//		//-----------------//				/**		 * Defines the parent <code>IMap</code> to look for the variables.		 */		public function get parent():IMap { return _parent; }		public function set parent(value:IMap):void { _parent = value; }				/**		 * Retrieves all the keys contained into the <code>IMap</code> and its parent.		 * 		 * @return	An <code>Array</code> containing all the keys.		 */		override public function keys():Array		{			var k:Array = super.keys();			if (parent!=null) k = k.concat(parent.keys());			return k;		}		/**		 * Retrieves all the values contained into the <code>IMap</code> and its parent.		 * 		 * @return	An <code>Array</code> containing all the values.		 */		override public function values():Array		{			var v:Array = super.values();			if (parent!=null) v.concat(parent.values());			return v;		}		/**		 * Retrieves the number of key-value mappings into the <code>IMap</code> and its parent.		 * 		 * @return	The number of key-value mappings.		 */		override public function size():uint		{			var s:uint = super.size();			if (parent!=null) s+=parent.size();			return s;		}		//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>TreeMap</code> object.		 * 		 * @param	parentMap	The parent <code>IMap</code>.		 * @param	weakKeys	Defines if the keys are weak references.		 */		public function TreeMap(parentMap:IMap=null, weakKeys:Boolean=false):void		{			super(weakKeys);						_parent = parentMap;		}				//--------------//		//Public methods//		//--------------//		/**		 * Returns <code>true</code> if this map contains a mapping for the specified key. If the key isn't found		 * in the current <code>TreeMap</code>, then it will be searched into the parent <code>IMap</code>.		 * 		 * @param		key		The key.		 * @return		<code>true</code> if the specified key is contained into the <code>IMap</code>.		 */		override public function containsKey(key:*):Boolean		{			var c:Boolean = super.containsKey(key);			if (c) return true;						return (parent==null) ? false : parent.containsKey(key);		}		/**		 * Returns true if this map maps one or more keys to the specified value. If the value isn't found		 * in the current <code>TreeMap</code>, then it will be searched into the parent <code>IMap</code>.		 * 		 * @param	value		The value.		 * @return	<code>true</code> if the specified value is contained into the <code>IMap</code>.		 */		override public function containsValue(value:*):Boolean		{			var c:Boolean = super.containsValue(value);			if (c) return true;						return (parent==null) ? false : parent.containsValue(value);		}		/**		 * Retrieves the value mapped to the specified key or <code>null</code> if there is no mapping for		 * the key. If the value is <code>null</code>, it will be searched into the parent <code>IMap</code>.		 * 		 * @param	key		The key.		 * @return	The object mapped to the specified key or <code>null</code>.		 */		override public function getValue(key:*):*		{			var v:* = super.getValue(key);			if (v==null && parent!=null) v = parent.getValue(key);			return v;		}		/**		 * Returns true if the <code>IMap</code> contains no key-value mappings. Both <code>parent</code> and current		 * <code>TreeMap</code> must be empty.		 * 		 * @return	<code>true</code> if there is no mapping into the <code>TreeMap</code> and its parent.		 */		override public function isEmpty():Boolean		{			var e:Boolean = super.isEmpty();			if (!e) return false;			return (parent==null) ? true : parent.isEmpty();		}				/**		 * Retrieves a <code>String</code> displaying all the key/value pairs of the <code>TreeMap</code> including its		 * parent <code>IMap</code>.		 * 		 * @return	A <code>String</code> representing the <code>TreeMap</code>.		 */		override public function toString():String		{			var str:String = super.toString();			return (parent==null) ? str : str+parent;		}				/**		 * Clears the current <code>TreeMap</code> and also clear its parent. If the parent <code>IMap</code> is also		 * a <code>TreeMap</code>, the <code>clearAll()</code> method is called, else the <code>clear()</code> method 		 * is called.		 */		public function clearAll():void		{			clear();						if (parent != null)			{				if (parent is TreeMap) (parent as TreeMap).clearAll();				else parent.clear();			}		}		//-----------------//		//Protected methods//		//-----------------//				//---------------//		//Private methods//		//---------------//	}}