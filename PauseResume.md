# How to pause/resume a download #

Since the MassLoader class has only the start() and stop() methods, it can also pause and resume the download. There is no pause() and resume() methods because the start() and stop() methods acts like them.

## Pause/Resume a download ##

You need simple to call the stop() method :
```
import ch.capi.net.*;

var massLoader:CompositeMassLoader = new CompositeMassLoader();

//add the files
var f1:ILoadableFile = massLoader.addFile("file1.swf");
var f2:ILoadableFile = massLoader.addFile("file2.swf");
var f3:ILoadableFile = massLoader.addFile("file3.swf");
var f4:ILoadableFile = massLoader.addFile("file4.swf");
var f5:ILoadableFile = massLoader.addFile("file5.swf");
var f6:ILoadableFile = massLoader.addFile("file6.swf");

//starts the download
massLoader.start();

//...
//after some actions/time
massLoader.stop(); //Pause the current loading
```

When the stop() method is called during a download, the files that are not totally loaded (Event.COMPLETE not dispatched) won't be removed from the loading queue. That allows you to add new files to the loading queue.

To resume the download, simply re-call the start() method :
```
//...
//after some actions/time
massLoader.stop(); //Pause the current loading

//...
//after some actions/time
massLoader.start();
```

## Doing a 'real' stop on the download ##

What does a 'real stop' mean ? Simply to clear the loading queue of the MassLoader.

```
massLoader.stop(); //like a pause()
massLoader.clear(); //no more file into the loading queue
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)