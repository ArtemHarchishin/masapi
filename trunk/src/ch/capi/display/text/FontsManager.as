package ch.capi.display.text
{
	import ch.capi.data.DictionnaryMap;
	import ch.capi.data.IMap;
	import ch.capi.errors.NameAlreadyExistsError;
	
	import flash.text.Font;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Manages the registered <code>Font</code>. Within this class, the <code>Font</code> registration
	 * is very easy : Just create your font symbol into the library, set it a linkage (the base class must
	 * be or extends <code>ch.capi.display.text.AbstractFont</code>) and then simply do the following :
	 * <listing version="3.0">
	 * //register the font
	 * var ab:AbstractFont = FontsManager.register("myFontClass", "linkageName");
	 * 
	 * //retrieves the font
	 * var ft:AbstractFont = FontsManager.getFont("linkageName");
	 * </listing>
	 * Note that this class is design to totally encapsulate the <code>Font</code> class. If you use this class,
	 * you shouldn't use the <code>Font</code> class methods.
	 * 
	 * @see			ch.capi.display.text.FontsParser		FontsParser
	 * @see			ch.capi.display.text.AbstractFont		AbstractFont
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public class FontsManager 
	{
		//---------//
		//Variables//
		//---------//
		private static var __linkage:IMap			= new DictionnaryMap(false);
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Register a class as a <code>Font</code>. As the retrieving of the <code>AbstractFont</code>
		 * object is based on the check of the <code>classPath</code> it is important that each of the
		 * registered font class extends the <code>AbstractFont</code> class.
		 * 
		 * @param	classPath		The full class name that will be registered. This class
		 * 							must extend the <code>AbstractFont</code> class !
		 * @param	linkageName		The linkage name.
		 * @return	The <code>AbstractFont</code> created.
		 * @throws	ch.capi.errors.NameAlreadyExistsError	If the linkage name is already used.
		 */
		public static function register(classPath:String, linkageName:String):AbstractFont
		{
			//check if the font is registered
			if (isRegistered(linkageName)) throw new NameAlreadyExistsError("Linkage name '"+linkageName+"' already exists");
			
			//register the font
			var fontClass:Class = getDefinitionByName(classPath) as Class;
			Font.registerFont(fontClass);
			
			//retrieves the instance
			var dt:Array = Font.enumerateFonts(false);
			var lf:AbstractFont = null;
			for (var i:uint=0 ; i<dt.length ; i++)
			{
				var cf:Font = dt[i] as Font;
				if (cf is fontClass)
				{
					lf = cf as AbstractFont;
					break;
				}
			}
			
			//this case should never be produced...
			if (lf == null) throw new Error("Font creation failed : "+classPath);
			
			//set the linkage & map
			lf.linkageName = linkageName;
			lf.textFormat.font = lf.fontName;
			__linkage.put(linkageName, lf);
			
			return lf;
		}
		
		/**
		 * Defines if the specified linkage name is already linked.
		 * 
		 * @param	linkageName		The linkage name.
		 * @return	<code>true</code> if the linkage is already linked.
		 */
		public static function isRegistered(linkageName:String):Boolean
		{
			return __linkage.containsKey(linkageName);
		}
		
		/**
		 * Retrieves the <code>AbstractFont</code> registered under the
		 * specified <code>linkageName</code>.
		 * 
		 * @param	linkageName		the linkage name.
		 * @return	The corresponding <code>AbstractFont</code>.
		 */
		public static function getFont(linkageName:String):AbstractFont
		{
			return __linkage.getValue(linkageName) as AbstractFont;
		}
		
		/**
		 * Retrieves the linkage names available.
		 * 
		 * @return	An <code>Array</code> containing all the available linkage names.
		 */
		public static function enumerateLinkages():Array
		{
			return __linkage.keys();
		}
	}
}