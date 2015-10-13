# About the progression information #

Masapi provides useful information about a massive loading. Those are all registered into a ILoadInfo object managed by the IMassLoader.

## Progression Listener ##

Here is a simple demo how to get those information. You created a massloader like that :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.addEventListener(ProgressEvent.PROGRESS, onMassiveLoadingProgress);

//...
cml.start();
```

You can simply access the massive loading information like that :
```
function onMassiveLoadingProgress(evt:ProgressEvent):void
{
	var source:IMassLoader = evt.target as IMassLoader;
	var infos:ILoadInfo = source.loadInfo;
	
	myField.text = infos.percentLoaded+"%";
	
	//useful for debbuging :
	//trace(infos.toString());
}
```

## Progression information ##

Masapi provides the following information :
  * bytesTotal : the bytes total to load.
  * bytesLoaded : the bytes loaded.
  * bytesRemaining : the bytes to load.
  * percentLoaded : the percentage loaded (0 - 100). This is an integer !
  * ratioLoaded : the ratio of bytes loaded (0 - 1). This is a floating Number !
  * elapsedTime : number of milliseconds since the start of the massive loading.
  * remainingTime : number of milliseconds expected until the end of the massive loading.
  * currentSpeed : the current speed of loading (bytes / second).
  * averageSpeed : the average speed of loading (bytes / second).
  * filesIdle : an Array containing the ILoadableFile that are in the queue list but not being currently loaded.
  * filesLoading : an Array containing the ILoadableFile that are currently being loaded.
  * filesSuccess : an Array containing the ILoadableFile successfully loaded.
  * filesError : an Array containing the ILoadableFile that fails to be downloaded.

Note that you can use the toString() method of ILoadInfo to easly display the information for debugging purposes !

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)