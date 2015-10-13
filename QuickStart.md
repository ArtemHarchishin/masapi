# Masapi Quick Start guide #

This is a simple guide that explain how to quickly start using the masapi main classes. You can find here how to [install masapi](http://code.google.com/p/masapi/wiki/Installation).

## Basic usage of masapi ##

Masapi contains three levels of classes to manage the massive loading :
  * The MassLoader that will load a list of files
  * The PriorityMassLoader that allows to specify a priority to a file
  * The ApplicationMassLoader that can manage the file dependencies

In order to avoid too much verbose code for basic usage, masapi also provides the CompositeMassLoader class that encapsulates all the most used features.

### Loading the files ###

The piece of code below shows how you can very simply use the CompositeMassLoader to load a list of files :
```
import ch.capi.net.*;

//creates the MassLoader
var cml:CompositeMassLoader = new CompositeMassLoader();

//creates & add the files to the MassLoader
cml.addFile("myFile.txt"); // will use a URLLoader object with the URLLoaderDataFormat.VARIABLES property
cml.addFile("myFile.xml"); // will use a URLLoader object with the URLLoaderDataFormat.TEXT property
cml.addFile("myFile.css"); // will use a URLLoader object with the URLLoaderDataFormat.TEXT property
cml.addFile("myFile.png"); // will use a URLLoader object with the URLLoaderDataFormat.BINARY property
cml.addFile("myFile.png", LoadableFileType.SWF); // will use a Loader object
cml.addFile("myFile.jpg"); // will use a URLLoader object with the URLLoaderDataFormat.BINARY property
cml.addFile("myFile.swf"); // will use a Loader object
cml.addFile("myFile.swf", LoadableFileType.BINARY); // will use a URLLoader object with the URLLoaderDataFormat.BINARY property

//starts the loading
cml.start();

//useful information for debugging
//trace(cml.massLoader);
```

You can also read how to [extend the supported file types](http://code.google.com/p/masapi/wiki/ExtendSupportedFileTypes) ! There is also a page that show [how to pause/resume a MassLoader](http://code.google.com/p/masapi/wiki/PauseResume).

In some cases, you will need to add your own [ILoadableFile types](http://code.google.com/p/masapi/wiki/ExtendSupportedLoadManagers).

### Listen to the massive loading events ###

Here is an exemple on how to listen to the MassLoader events :
```
import ch.capi.net.*;
import ch.capi.events.*;

//creates the MassLoader
var cml:CompositeMassLoader = new CompositeMassLoader();

cml.massLoader.addEventListener(ProgressEvent.PROGRESS, onOverallProgress); //overall progression
cml.massLoader.addEventListener(MassLoadEvent.FILE_OPEN, onOpenHandler); //a file download starts
cml.massLoader.addEventListener(Event.COMPLETE, completeHandler); //massload complete

//... (creates the files and so on)

//listen to the overall progression
function onOverallProgress(evt:ProgressEvent):void
{
    var percent:Number = Math.round(evt.bytesLoaded / evt.bytesTotal * 100);
    trace("Loaded at "+percent+"%");
}

//listen when a file begins to be loaded
function onOpenHandler(evt:MassLoadEvent):void
{
	var file:ILoadableFile = evt.file as ILoadableFile;
	file.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
}

//listen to a specific file
function onFileProgress(evt:ProgressEvent):void
{
	trace("file progress");
}

//listen to the complete event
function completeHandler(evt:Event):void
{
    trace("MassLoad complete");
}

//starts the loading
cml.start();
```

Here is another page about [download errors](http://code.google.com/p/masapi/wiki/ErrorsHandling) !

### Get progression information ###

A Massloader provides a ILoadInfo object that has very useful information (speed, elapsed time, remaining time, ...).

```
import ch.capi.net.*;
import ch.capi.events.*;

//creates the MassLoader
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
//...

function onProgress(evt:ProgressEvent):void
{
	var info:ILoadInfo = evt.target.loadInfo;
	//var info:ILoadInfo = cml.loadInfo;
	
	trace(info.currentSpeed);
	trace(info.averageSpeed);
	trace(info.elapsedTime);
	trace(info.remainingTime);
	trace(info.percentLoaded);
	trace(info.ratioLoaded);
	trace(info.bytesLoaded+" / "+info.bytesTotal);
}
```

Here is more about the [progression information](http://code.google.com/p/masapi/wiki/ProgressionInfo).

### Retrieves the data of the loaded files ###

There are many ways to retrieve the data of the loaded files. This depends of which type of file you are loading and which variant you choose. Be aware that Masapi will not keep any reference on the ILoadableFile that have been loaded !

You'll find more information on [this page](http://code.google.com/p/masapi/wiki/RetrieveData).

The easiest way is to use the getData() method of the ILoadableFile interface :
```
import ch.capi.net.*;

var cml:CompositeMassLoader = new CompositeMassLoader();
var file1:ILoadableFile = cml.addFile("test.swf", LoadableFileType.BINARY); //use a URLLoader object with the URLLoaderDataFormat.BINARY property
var file2:ILoadableFile = cml.addFile("test2.swf"); //use a Loader object

//... (waits for the massive loading complete)

var loaderData:ByteArray = file1.getData();
var loader1:Loader = file1.getData("flash.display.Loader");
var loader2:Loader = file2.getData();
```

Some more samples :
```

var file:ILoadableFile = cml.addFile("dataFile");

//if dataFile contains a XML
var asString:String = file.getData();
var asXml:XML = file.getData("XML");
var asXmlDocument:XMLDocument = file.getData("flash.xml.XMLDocument");

//if dataFile contains a CSS
var asStyleSheet:StyleSheet = file.getData("flash.text.StyleSheet");

//if dataFile contains variables
var asVariables:URLVariables = file.getData("flash.net.URLVariables"); //file.getData() also works

//if dataFile contains binary values
var asByteArray:ByteArray = file.getData("flash.utils.ByteArray"); //file.getData() also works
var asLoader:Loader = file.getData("flash.display.Loader");
```

## Avoid some basic problems ##

If you're working with masapi using AS3 classes, just keep in mind that you must have an explicit reference to your CompositeMassLoader or MassLoader in order that it won't be collected by the Garbage Collector.

```
package
{
	import ch.capi.net.*;

	public class BadWayClass
	{
		public function myLoadMethod():void
		{
			var cml:CompositeMassLoader = new CompositeMassLoader();
			
			cml.addFile("file.swf");
			cml.addFile("file.txt");
			cml.addFile("file.xml");
			
			cml.addEventListener(Event.COMPLETE, onLoadComplete);
			
			cml.start();
		}
		
		protected function onLoadComplete(evt:Event):void
		{
			trace("okay !");
		}
	}
}
```
In that case, the onLoadComplete function will probably never be called because when the Flash Player quits the myLoadMethod, it will say to the Garbage Collector something like 'okay you can delete all this stuff'.

The solution is right simple : just keep a reference into your class !
```
package
{
	import ch.capi.net.*;

	public class RightWayClass
	{
		private var _massLoader:CompositeMassLoader;
	
		public function myLoadMethod():void
		{
			var cml:CompositeMassLoader = new CompositeMassLoader();
			
			cml.addFile("file.swf");
			cml.addFile("file.txt");
			cml.addFile("file.xml");
			
			cml.addEventListener(Event.COMPLETE, onLoadComplete);
			
			cml.start();
			
			_massLoader = cml;
		}
		
		protected function onLoadComplete(evt:Event):void
		{
			trace("okay !");
		}
	}
}
```

## Samples ##

You will find complete samples into the [bundles](http://code.google.com/p/masapi/source/browse/trunk/bundles/). And you're now ready to have a look to the [User Guide](http://code.google.com/p/masapi/wiki/UserGuide) !