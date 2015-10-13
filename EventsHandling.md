# How to listen to the masapi's events #

Masapi manages the events in a standard way, as the core AS3 classes.

## ILoadablefile events ##

All the implementations of ILoadableFile send the following events :
  * Event.OPEN - the loading starts
  * ProgressEvent.PROGRESS - the loading progresses
  * Event.COMPLETE - the loading is complete
  * Event.CLOSE - the loading has been stopped
  * IOErrorEvent.IO\_ERROR - a I/O error occured
  * SecurityErrorEvent.SECURITY\_ERROR - a security error occured
  * (Event.INIT) - when the content can be accessed (only for the LoadableFileType.SWF ILoadableFile instances)

### the standard way ###
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var file1:ILoadableFile = cml.addFile("aFile.xml");
file1.addEventListener(Event.OPEN, handleOpen);
file1.addEventListener(ProgressEvent.PROGRESS, handleProgress);
file1.addEventListener(Event.COMPLETE, handleComplete);

function handleOpen(evt:Event):void { trace("open"); }
function handleProgress(evt:ProgressEvent):void { trace("progress"); }
function handleComplete(evt:Event):void { trace("complete"); }

//...
cml.start();
```

### the other way ###
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.addFile("aFile.xml", LoadableFileType.TEXT, handleOpen, handleProgress, handleComplete); //weak references to the listeners !

function handleOpen(evt:Event):void { trace("open"); }
function handleProgress(evt:ProgressEvent):void { trace("progress"); }
function handleComplete(evt:Event):void { trace("complete"); }

//...
cml.start();
```

There is also the attachListener method that let you register some listeners to a ILoadableFile. Note that all listeners use weak references !

## MassLoader events ##

A IMassLoader send the following events :
  * Event.OPEN - the massive loading starts
  * ProgressEvent.PROGRESS - the massive loading progresses
  * Event.COMPLETE - the massive loading is complete
  * Event.CLOSE - the massive loading has been stopped (paused)
  * MassLoadEvent.FILE\_OPEN - the MassLoader starts the loading of a ILoadManager (which can be a ILoadableFile or IMassLoader)
  * MassLoadEvent.FILE\_CLOSE - the download of a ILoadManager is finished (success or failure)

```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.addEventListener(Event.OPEN, handleOpen);
cml.massLoader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
cml.massLoader.addEventListener(Event.COMPLETE, handleComplete);
cml.massLoader.addEventListener(MassLoadEvent.FILE_OPEN, handleFileOpen);
cml.massLoader.addEventListener(MassLoadEvent.FILE_CLOSE, handleFileClose);

function handleOpen(evt:Event):void { trace("open"); }
function handleProgress(evt:ProgressEvent):void { trace("progress"); }
function handleComplete(evt:Event):void { trace("complete"); }
function handleFileOpen(evt:MassLoadEvent):void { trace("fileOpen"); }
function handlefileClose(evt:MassLoadEvent):void { trace("fileClose"); }

//...
cml.start();
```

### A MassLoader into a MassLoader ###

In the most common cases, you will simply load files. Masapi supports that you put a IMassLoader into another one like that :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.addFile("file1.txt");
cml.addFile("file2.xml");

var inCml:CompositeMassLoader = new CompositeMassLoader();
inCml.addFile("other.swf");
inCml.addFile("other2.xml");
cml.massLoader.addFile(inCml.massLoader);

//...
cml.start();
```

In that case, maybe you should reconsider your way and use the [file dependencies](http://code.google.com/p/masapi/wiki/FileDependencies) or a CompositePriorityMassLoader !


### About FILE\_OPEN and FILE\_CLOSE ###

Those both events let you retrive what is the current file being loaded/closed.
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.addEventListener(MassLoadEvent.FILE_OPEN, handleEvent);
cml.massLoader.addEventListener(MassLoadEvent.FILE_CLOSE, handleEvent);

function handleEvent(evt:MassLoadEvent):void
{
	var currentFile:ILoadableFile = evt.file as ILoadableFile; 
	trace(currentFile.urlRequest.url);
}

//...
cml.start();
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)