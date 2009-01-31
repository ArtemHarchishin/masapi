package ch.capi.utils{	import ch.capi.data.DictionnaryMap;		import flash.errors.IllegalOperationError;		import ch.capi.data.IMap;		
	/**	 * Useful class to performe some replacements into a text, using an <code>IMap</code> to	 * store the pairs of key/values.	 * 	 * @author		Cedric Tabin - thecaptain	 * @version		1.0	 */	public class VariableReplacer	{		//---------//		//Constants//		//---------//				//---------//		//Variables//		//---------//		private var _variables:IMap;		private var _regexp:RegExp;		private var _replacements:uint;		/**		 * Defines the regular expression for the variables. By default, a variable is always of		 * the form ${VARIABLE_NAME}.		 */		public static var defaultVariableRegexp:RegExp = /\${(.*?)}/g;
		//-----------------//		//Getters & Setters//		//-----------------//				/**		 * Defines the number of replacements done on the last <code>String</code>. 		 */		public function get replacementCount():uint { return _replacements; }				/**		 * Defines the regular expression of the variables. This regular expression must		 * have at least one parenthesis matching group.		 */		public function get regexp():RegExp { return _regexp; }		public function set regexp(value:RegExp):void		{			if (value == null) throw new IllegalOperationError("The value is not defined");			_regexp = value;		}		/**		 * Defines the <code>IMap</code> that contains all pairs variable/value.		 */		public function get variables():IMap { return _variables; }		public function set variables(value:IMap):void		{			if (value == null) throw new IllegalOperationError("The value is not defined");			_variables = value;		}		//-----------//		//Constructor//		//-----------//				/**		 * Creates a new <code>VariableReplacer</code> object.		 * 		 * @param	variables	The variables of the replacer. If no <code>IMap</code> is specified, then		 * 						a <code>DictionnaryMap</code> will be used.		 * @param	regexp		The regular expression for the variables. This regular expression must		 * 						have at least one parenthesis matching group.		 */		public function VariableReplacer(variables:IMap=null, regexp:RegExp=null):void		{			if (regexp == null) regexp = defaultVariableRegexp;			if (variables == null) variables = new DictionnaryMap();						_variables = variables;			_regexp = regexp;		}		//--------------//		//Public methods//		//--------------//		/**		 * Replaces the variables into the source <code>String</code> using the specified regular expression. This		 * is a utility method for a fast useablility.		 * 		 * @param	source		The source <code>String</code>.		 * @param	variables	The variables.		 * @param	regexp		The regular expression of the variable.		 * @return	The <code>String</code> with the replaced variables.		 */		public static function replace(source:String, variables:IMap, regexp:RegExp=null):String		{			return new VariableReplacer(variables, regexp).replaceVars(source);		}				/**		 * Replaces the specified variable into the source <code>String</code> using the specified regular expression.		 * This is a utility method for a fast useablility.		 * 		 * @param	source			The source <code>String</code>.		 * @param	variableName	The name of the variable (ID into ${ID} with the default RegExp).		 * @param	value			The value to set in place of the variable.		 * @param	regexp			The regular expression of the variable.		 * @return	The <code>String</code> with the replaced variables.		 */		public static function replaceVar(source:String, variableName:String, value:String, regexp:RegExp=null):String		{			var map:IMap = new DictionnaryMap();			map.put(variableName, value);			return replace(source, map, regexp);		}		/**		 * Replaces all the variables contained into the source <code>String</code> using the specified		 * <code>IMap</code> as source for the variables. If a variable isn't found, a null value is put		 * in place of the variable.		 * 		 * @param	source		The source <code>String</code> to do the replacement.		 * @return	The updated <code>String</code> with values.		 */		public function replaceVars(source:String):String		{			_replacements = 0;			var localReplace:int = 0;						do			{				_regexp.lastIndex = 0;					localReplace = 0;				var m:Matcher = new Matcher(_regexp, source);				while (m.find())				{					var variableName:String = m.group(1); //retrieves the variable name										//replace the variable by the value					var value:Object = _variables.getValue(variableName);					m.appendReplacement(value.toString());										localReplace++;					_replacements++;				}				m.appendTail();								source = m.toString();			}			while (localReplace > 0);						return source;		}		//-----------------//		//Protected methods//		//-----------------//				//---------------//		//Private methods//		//---------------//	}}