package ch.capi.display.text
{
	import ch.capi.utils.ParseUtils;		import ch.capi.errors.ParseError;
	import flash.xml.XMLNode;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * Parser of embed fonts. The principle is that the swf containing the fonts are
	 * loaded within a <code>Loader</code> object and then, the <code>EmbedFontParser</code> will
	 * register the <code>Font</code> from an <code>XMLNode</code>.
	 * 
	 * @see			ch.capi.display.text.FontsManager	FontsManager
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.1
	 */
	public class FontsParser
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Attribute name of 'name'.
		 */
		private static const ATTRIBUTE_NAME_VALUE:String = "name";
		
		/**
		 * Attribute name of 'class'.
		 */
		private static const ATTRIBUTE_CLASS_VALUE:String = "class";
		
		//---------//
		//Variables//
		//---------//
		private var _defaultSize:uint = 12;
		private var _defaultColor:uint = 0;
		private var _defaultAlign:String = TextFormatAlign.LEFT;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the default alignement if the attribute is not specified.
		 */
		public function get defaultAlign():String { return _defaultAlign; }
		public function set defaultAlign(value:String):void { _defaultAlign = value; }
		
		/**
		 * Defines the default size if attribute not specified.
		 */
		public function get defaultSize():uint { return _defaultSize; }
		public function set defaultSize(value:uint):void { _defaultSize = value; }
		
		/**
		 * Defines the default color if attribute not specified.
		 */
		public function get defaultColor():uint { return _defaultColor; }
		public function set defaultColor(value:uint):void { _defaultColor = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>FontsParser</code> object.
		 */
		public function FontsParser():void { }
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Parse the <code>Font</code> contained into the <code>XMLNode</code>.
		 * 
		 * @param	node		The node to parse.
		 * @throws	ch.capi.errors.ParseError	If the <code>XMLNode</code> is invalid.
		 */
		public function parse(node:XMLNode):void
		{
			var l:uint = node.childNodes.length;
			for (var i:uint=0 ; i<l ; i++)
			{
				var n:XMLNode = node.childNodes[i];
				parseNode(n);
			}
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Initialize the <code>AbstractFont</code>.
		 * 
		 * @param	font	The <code>AbstractFont</code> to initialize.
		 * @param	node	The <code>XMLNode</code>.
		 */
		protected function initializeFont(font:AbstractFont, node:XMLNode):void
		{
			var fo:TextFormat = font.textFormat;
			
			var att:Object = node.attributes;
			fo.align = (att.align == null) ? defaultAlign : att.align;
			fo.bold = ParseUtils.parseBoolean(att.bold);
			fo.color = (att.color == null) ? defaultColor : ParseUtils.parseUnsigned(att.color);
			fo.italic = ParseUtils.parseBoolean(att.italic);
			fo.size = (att.size == null) ? defaultSize : ParseUtils.parseUnsigned(att.size);
			fo.underline = ParseUtils.parseBoolean(att.underline);
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function parseNode(node:XMLNode):AbstractFont
		{
			var name:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (name == null) throw new ParseError("parse", "Attribute '"+ATTRIBUTE_NAME_VALUE+"' is not defined", node);
			if (FontsManager.isRegistered(name)) throw new ParseError("register", "Font '"+name+"' is already registred", node);
			
			var className:String = node.attributes[ATTRIBUTE_CLASS_VALUE];
			if (className == null) throw new ParseError("parse", "Attribute '"+ATTRIBUTE_CLASS_VALUE+"' is not defined", node);
			
			var af:AbstractFont = FontsManager.register(className, name);
			initializeFont(af, node);
			
			return af;
		}
	}
}