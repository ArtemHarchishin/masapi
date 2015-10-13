# How to handle the download errors #

Since a download can fail, there are two main ways within masapi to retrieve those errors. You can simple listen to the ILoadableFile events if you want to handle errors on a specific file or to the MassLoadEvent.FILE\_CLOSE event to know if a file hasn't been downloaded.

## ILoadableFile events ##

A ILoadableFile object send events like a load manager (URLLoader, Loader, ...). You can add your listeners as usual to get the errors. You may also look at this page : [Masapi's events](http://code.google.com/p/masapi/wiki/EventsHandling) !

```
var myFile:ILoadbleFile = ...
myFile.addEventListener(IOErrorEvent.IO_ERROR, ioError);
myFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);

function ioError(evt:IOErrorEvent):void { trace("ioError"); }
function securityError(evt:SecurityErrorEvent):void { trace("securityError"); }
```

## MassLoadEvent.FILE\_CLOSE ##

This event is sent whenever a file is downloaded successfully or not. The MassLoadEvent class let you retrieve the event that the MassLoader received.

```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.addEventListener(MassLoadEvent.FILE_CLOSE, fileClose);

function fileClose(evt:MassLoadEvent):void
{
   var file:ILoadManager = evt.file;
   if (evt.isError()) //oh ! the file hasn't been loaded successfully !
   {
     var errorEvent:Event = evt.closeEvent;
     var message:String = errorEvent.message;
     trace("The file "+file+" hasn't been loaded successfully : "+message+" ("+errorEvent.type+")");
   }
   else
   {
   	 trace("The file "+file+" is now loaded and ready to use");
   }
}
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)