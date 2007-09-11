package ch.capi.display.text
{
	import ch.capi.errors.ParseError;
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
	 * @version		1.0
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
			fo.align = (att.align == null) ? TextFormatAlign.LEFT : att.align;
			fo.bold = (att.bold == true.toString());
			fo.color = (att.color == null) ? 0 : att.color;
			fo.italic = (att.italic == true.toString());
			fo.size = (att.size == null) ? 12 : att.size;
			fo.underline = (att.align == true.toString());
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		protected function parseNode(node:XMLNode):AbstractFont
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