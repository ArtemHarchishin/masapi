# How to retrieve the data of loaded files #

Masapi can handles any kind of file types. Basically, its support all the most used file types. The data that are in each of them can be in the most case handle automatically by masapi.

## The getData method ##

It is very easy to avoid the basic lines of code, for instance to load binary data into a Loader object. The getData method allows you to give a class name that you want to have in return. If you don't specify anything, then masapi will just return the data that was received.

## Using the basic way ##

The most of the time, you will probably use that way to load different type of data (xml, variables, binary, ...) and then parse them to the right object. Just see how it's simple to handle that with masapi :

```
var file:ILoadableFile = compositeML.addFile("content.xml");
//...

var rawData:String = file.getData();
var asXml:XML = file.getData("XML");
var asXmlDocument:XMLDocument = file.getData("flash.xml.XMLDocument");
```
As you see, you don't need to have some extra-lines to parse the data. You just need to specify the full class name of the class that you want to use (yes, that means that you can specify you own one, see below).

```
var file:ILoadableFile = compositeML.addFile("content.css");
//...

var rawData:String = file.getData();
var asCSS:StyleSheet = file.getData("flash.text.StyleSheet");
```

The most interessant case is to see how it works with a Loader.
```
var file:ILoadableFile = compositeML.addFile("content.swf"); //Use directly a Loader object
//...

var asLoader:Loader = file.getData();
//var asLoader:Loader = file.getData("flash.display.Loader");
```
It isn't necessary to give the class name, because masapi already uses a Loader object to load the data. But it is possible, so event if you set your file as a LoadableFileType.BINARY, you'll get a Loader instead of a ByteArray.

```
var file:ILoadableFile = compositeML.addFile("content.swf", LoadableFileType.BINARY); //Use a URLLoader object
//...

var asRawData:ByteArray = file.getData();
var asLoader:Loader = file.getData("flash.display.Loader");
```

Using this way, you can dynamically manage if you want to stream your SWF (LoadableFileType.SWF) or not (LoadableFileType.BINARY).

### About the Loader and LoaderContext ###

The both lines below can have different consequences on your application :
```
var file1:ILoadableFile = compositeML.addFile("file1.swf"); //LoadableFileType.SWF
var file2:ILoadalbeFile = compositeML.addFile("file2.swf", LoadableFileType.BINARY);

var ld1:Loader = file1.getData();
var ld2:Loader = file2.getData("flash.display.Loader");
```

The first file (file1) will be loaded in the current ApplicationDomain, but  the second one will be loaded in a sub-ApplicationDomain. If you want to have them to have the same behavior, you must write the code yourself :
```
var file1:ILoadableFile = compositeML.addFile("file1.swf"); //LoadableFileType.SWF
var file2:ILoadalbeFile = compositeML.addFile("file2.swf", LoadableFileType.BINARY);

var ld1:Loader = file1.getData();

var rawData:ByteArray = file2.getData();
var ld2:Loader = new Loader();
var ctx:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
ld2.loadBytes(rawData, ctx);
```

## Customize your parsers ##

There can be some cases where the basic classes (Loader, XMLDocument, ...) aren't sufficient for your purposes. Basically, it is easy to get the raw data and send them to your own parser.

In the case of your parser extends one of the basic classes, then you can just avoid thos lines of code :
```
package ch.test
{
	import flash.display.Loader;

	public class MyLoader extends Loader
	{
		public override loadBytes(data:ByteArray):void
		{
			trace("loading bytes...");
			super.loadBytes(data);
		}
	}
}
```

You can use your class like that :
```
var file:ILoadableFile = compositeML.addFile("file.jpg", LoadableFileType.BINARY);
//...

var myLoader:MyLoader = file.getData("ch.test.MyLoader");

/*
Instead of :
var rawData:ByteArray = file.getData();
var myLoader:MyLoader = new MyLoader();
myLoader.loadBytes(rawData);
*/
```

The only thing you must do into your class is to override the parsing method (loadBytes, parseXML, parseCSS, ...) if you need it. To know if a class is supported, you can simply use the isClassSupported method !

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)