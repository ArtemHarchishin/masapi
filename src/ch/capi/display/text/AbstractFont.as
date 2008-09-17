package ch.capi.display.text
{
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	/**
	 * Root level class for the <code>Font</code> that will be
	 * managed by the <code>FontManager</code> class.
	 * 
	 * @see			ch.capi.display.text.FontsManager	FontsManager
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class AbstractFont extends Font
	{
		//---------//
		//Variables//
		//---------//
		private var _linkage:String;
		private var _format:TextFormat		= new TextFormat();
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the linkage name.
		 */
		public function get linkageName():String { return _linkage; }
		public function set linkageName(value:String):void { _linkage = value; }
		
		/**
		 * Defines the <code>TextFormat</code>.
		 */
		public function get textFormat():TextFormat { return _format; }
		public function set textFormat(value:TextFormat):void { _format = value; }
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>AbstractFont</code> object.
		 * 
		 * @param	linkageName		The linkage name.
		 */
		public function AbstractFont(linkageName:String=null):void
		{
			_linkage = linkageName;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves a copy of the <code>TextFormat</code> used by this <code>AbstractFont</code>.
		 * <p>Be aware that the <code>tabStops</code> Array is copied by reference which means that if you
		 * modify it, the modifications will be also translated to the <code>textFormat</code> property.</p>
		 * 
		 * @return	A copy of the <code>textFormat</code> property.
		 */
		public function getTextFormatCopy():TextFormat
		{
			var copy:TextFormat = new TextFormat();
			copy.align = textFormat.align;
			copy.blockIndent = textFormat.blockIndent;
			copy.bold = textFormat.bold;
			copy.bullet = textFormat.bullet;
			copy.color = textFormat.color;
			copy.display = textFormat.display;
			copy.font = textFormat.font;
			copy.indent = textFormat.indent;
			copy.italic = textFormat.italic;
			copy.kerning = textFormat.kerning;
			copy.leading = textFormat.leading;
			copy.leftMargin = textFormat.leftMargin;
			copy.letterSpacing = textFormat.letterSpacing;
			copy.rightMargin = textFormat.rightMargin;
			copy.size = textFormat.size;
			copy.tabStops = textFormat.tabStops;  /* !!! Reference copy !!! */
			copy.target = textFormat.target;
			copy.underline = textFormat.underline;
			copy.url = textFormat.url;
			
			return copy;
		}
		
		/**
		 * Applies the <code>TextFormat</code> to the specified <code>TextField</code>.
		 * 
		 * @param	field			The <code>TextField</code>.
		 * @param	allProperties	Defines if all the properties of the <code>TextFormat</code> must be applied. If not,
		 * 							then only the font is applied.
		 * @param	setAsDefault	Defines if the <code>TextFormat</code> must be set as default for the specified <code>TextField</code>.
		 */
		public function applyFormat(field:TextField, allProperties:Boolean=true, setAsDefault:Boolean=true):void
		{
			field.embedFonts = true;
			
			var tf:TextFormat = textFormat;
			
			//apply only the font
			if (!allProperties) 
			{
				tf = new TextFormat();
				tf.font = textFormat.font;
			}
			
			//set as default TextFormat
			if (setAsDefault) field.defaultTextFormat = tf;
			
			//apply the TextFormat
			field.setTextFormat(tf);
		}
	}
}