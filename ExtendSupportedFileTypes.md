# Supported file types #

All the supported file types are listed into the LoadableFileType class constants. Within those constants, you can choose which type of ILoadableFile you retrieve from the LoadableFileFactory (or CompositeMassLoader).

By default, masapi uses the ExtensionFileSelector to determine the type of the files that you want to load. The following extensions are built-in :
  * swf (LoadableFileType.SWF) => all SWF files will be loaded with a Loader object.
  * txt (LoadableFileType.VARIABLES) => all txt files will be loaded with a URLLoader object using the URLLoaderDataFormat.VARIABLES format.
  * xml/css (LoadableFileType.TEXT) => all xml/css files will be loaded with a URLLoader object using the URLLoaderDataFormat.TEXT format.
  * jpg/jpeg/gif/png (LoadableFileType.BINARY) => all jpg/jpeg/gif/png files will be loaded with a URLLoader object using the URLLoaderDataFormat.BINARY format.
  * mp3/wav (LoadableFileType.SOUND) => all mp3/wav files will be loaded with a Sound object.
  * no extension (LoadableFileType.STREAM) => all files with no extension will be loaded using a URLStream object.

For example, the following files are created using the rules above :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var ilf1:ILoadableFile = cml.addFile("aFile.swf"); //Loader object
var ilf2:ILoadableFile = cml.addFile("aFile.txt"); //URLLoader object using URLLoaderDataFormat.VARIABLES
//...

var factory:LoadableFileFactory = new LoadableFileFactory();
var ilf3:ILoadableFile = factory.create("aFile.jpg"); //URLLoader object with URLLoaderDataFormat.BINARY
var ilf4:ILoadableFile = factory.create("aFile.mp3"); //Sound object
//...
```

It is also possible to defines which type of load manager object you want to use :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var ilf1:ILoadableFile = cml.addFile("aFile.swf", LoadableFileType.BINARY); //URLLoader object using URLLoaderDataFormat.BINARY
var ilf2:ILoadableFile = cml.addFile("aFile.txt", LoadableFileType.TEXT); //URLLoader object using URLLoaderDataFormat.TEXT
//...

/*
For the LoadableFileFactory class, you need to specify manually the load manager object using the methods you have (createURLLoaderFile, createLoaderFile, createSoundFile, createURLStreamFile)
*/
```


# Extend the supported file types by default #

Masapi let you easily defines new extensions that you want to map by default to a predefined file type.
```
var sl:ExtensionFileSelector = new ExtensionFileSelector();
sl.extensions.put("html", LoadableFileType.TEXT);

//you can also override predefined type
sl.extensions.put("jpg", LoadableFileType.SWF);

var factory:LoadableFileFactory = new LoadableFileFactory(sl);
var cml:CompositeMassLoader = new CompositeMassLoader(null, sl);
```

Here is a shorter way to do the same thing above :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var elf:ExtensionFileSelector = (cml.loadableFileFactory.loadableFileSelector as ExtensionFileSelector);
elf.extensions.put("html", LoadableFileType.TEXT);
```

It would be also a much advanced way to extend the ExtensionFileSelector to put a more extended list of extensions.


# Extend the supported file types (objects) #

In few cases, the methods given above won't be sufficient and you will need to create some new classes that can manage other load manager object (that means **not** a Loader, URLLoader, URLStream or Sound classes). For that way you'll need to implement the ILoadableFile interface to your specific class.

Note that you can extend the AbstractLoadableFile class that already implements a lot of needed methods. There is just an important line to put in your constructor : the registration to the load manager object.
```
public function SLoadableFile(snd:Sound):void
{
	super(snd);
	registerTo(snd);	
}
```
You need to register the object that sends the loading events. For example, for a Loader object :
```
public function LLoadableFile(loadObject:Loader):void
{
	super(loadObject);
			
	var dispatcher:IEventDispatcher = loadObject.contentLoaderInfo;
	registerTo(dispatcher);
	//dispatcher.addEventListener(Event.INIT, onInit);
}
```

You can check the default classes that manages the built-in load manager objects :
  * Loader : ch.capi.net.LLoadableFile
  * URLLoader : ch.capi.net.ULoadableFile
  * URLStream : ch.capi.net.RLoadableFile
  * Sound : ch.capi.net.SLoadableFile
Note that thoses classes are internal and you can't directly access them trought the API !

If you don't want/can extend the AbstractLoadableFile class, you'll need to redirect all loading events that are managed by the load manager object. In the order to work correctly, the following ones need to be dispatched by your ILoadableFile implementation :
  * Event.OPEN
  * Event.COMPLETE
  * ProgressEvent.PROGRESS

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)