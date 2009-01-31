package ch.capi.data.text{	import ch.capi.utils.ParseUtils;		import ch.capi.utils.Matcher;		import ch.capi.data.DictionnaryMap;		import ch.capi.data.IMap;		
	/**	 * The Properties class can store and parse some key/value pairs.	 * 	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public class Properties	{		//---------//		//Constants//		//---------//		private static const PARSE_REGEXP:RegExp = /(.*?)=(.*)/g;		//---------//		//Variables//		//---------//		private var _variables:IMap 	= new DictionnaryMap();		//-----------------//		//Getters & Setters//		//-----------------//				/**		 * Defines the variables contained into the <code>Properties</code>.		 */		public function get variables():IMap { return _variables; }				//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>Properties</code> object.		 * 		 * @param	src		The source to parse.		 */		public function Properties(src:String=null):void		{			if (src != null) parse(src);		}				//--------------//		//Public methods//		//--------------//		/**		 * Maps the specified key with the value. If the key is already set, the value will be erased by		 * the new one.		 * 		 * @param	key		The key.		 * @param	value	The value.		 */		public function setValue(key:String, value:String):void		{			_variables.put(key, value);		}		/**		 * Retrieves the value of the specified key. If the key doesn't exist, then <code>null</code>		 * is returned.		 * 		 * @param	key		The key.		 * @return	The value or <code>null</code>.		 */		public function getValue(key:String):*		{			return _variables.getValue(key);		}		/**		 * Retrieves the value of the specified key as integer.		 * 		 * @param	key		The key.		 * @return	The value as integer.		 * @throws	Error	If the value is not an integer.		 */		public function getValueAsInt(key:String):int		{			var value:Object = _variables.getValue(key);			if (!value is String) throw new Error("The key '"+key+"' is not a string value");						return ParseUtils.parseInteger(value as String);		}				/**		 * Retrieves the value of the specified key as Number.		 * 		 * @param	key		The key.		 * @return	The value as Number.		 * @throws	Error	If the value is not an Number.		 */		public function getValueAsNumber(key:String):Number		{			var value:Object = _variables.getValue(key);			if (!value is String) throw new Error("The key '"+key+"' is not a string value");						return ParseUtils.parseNumber(value as String);		}				/**		 * Retrieves the value of the specified key as unsigned integer.		 * 		 * @param	key		The key.		 * @return	The value as unsigned integer.		 * @throws	Error	If the value is not an unsigned integer.		 */		public function getValueAsUnsigned(key:String):uint		{			var value:Object = _variables.getValue(key);			if (!value is String) throw new Error("The key '"+key+"' is not a string value");						return ParseUtils.parseUnsigned(value as String);		}				/**		 * Retrieves the value of the specified key as Boolean.		 * 		 * @param	key		The key.		 * @return	The value as Boolean.		 * @throws	Error	If the value is not a Boolean.		 */		public function getValueAsBoolean(key:String):Boolean		{			var value:Object = _variables.getValue(key);			if (!value is String) throw new Error("The key '"+key+"' is not a string value");						return ParseUtils.parseBoolean(value as String);		}		/**		 * Parses the specified source. The source must be a list of variables formatted like that <code>key=value</code>		 * on each line. The old key/value pairs are kept.		 * 		 * @param	src		The source to parse.		 */		public function parse(src:String):void		{			var matcher:Matcher = new Matcher(PARSE_REGEXP, src);			while (matcher.find())			{				var key:String = matcher.group(1);				var value:String = matcher.group(2);					_variables.put(key, value);			}		}				/**		 * Deletes all the key/value pairs.		 */		public function clear():void		{			_variables.clear();		}		//-----------------//		//Protected methods//		//-----------------//				//---------------//		//Private methods//		//---------------//	}}