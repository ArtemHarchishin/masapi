# Embedded Fonts Management #

Masapi includes some classes that let you easly manage embedded fonts into your flash applications.

## Embedding a Font ##

Just add your font into your library as usual. Then, in the linkage options, set 'ch.capi.display.text.AbstractFont' into the super class field. You can put your own class name into the class field. If that is a class you wrote, then it must also extends AbstractFont (it extends Font).

In order to use your embedded font into all your SWFs, you need to register it. The following code take place into the SWF that contains the embedded font :
```
import ch.capi.display.text.FontsManager;

FontsManager.registerFont("classNameOfYourFont", "aLinkageName");
```

## Using the Embedded Font ##

Once your font is embedded, it is really easy to use it into another SWF :
```
import ch.capi.display.text.FontsManager;

var myFont:AbstractFont = FontsManager.getFont("aLinkageName");
var format:TextFormat = new TextFormat();
format.font = myFont.fontName;

myField.setTextFormat(format);
```

You can also use the AbstractFont useful method :
```
import ch.capi.display.text.FontsManager;

var myFont:AbstractFont = FontsManager.getFont("aLinkageName");
myFont.applyFormat(myTextField);
```

[Here](http://www.astorm.ch/blog/index.php?post/2008/02/24/gestion-de-polices-integrees-embedded-fonts) is another french tutorial about the embedded fonts !

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)