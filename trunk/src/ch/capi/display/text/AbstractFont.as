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