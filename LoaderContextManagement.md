# LoaderContext management #

By default, Masapi will load all the SWF (LoadableFile.SWF or LoadableFile.BINARY with getData("flash.display.Loader")) into the same application domain of the loader SWF.

## Retrieve the LoaderContext ##

By default, the LoadableFileFactory handles a defaultLoaderContext property that will be used to create the new ILoadableFile of type LoadableFileType.SWF.
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var defaultContext:LoaderContext = cml.loadableFileFactory.defaultLoaderContext;
```

There is currently no way to extract the LoaderContext directly from a ILoadableFile object.

## Setting a specific LoaderContext for all the files ##

Just override the defaultLoaderContext property :
```
var ctx:LoaderContext = new LoaderContext(false, new ApplicationDomain());
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.loadableFileFactory.defaultLoaderContext = ctx;

//...
var file:ILoadableFile = cml.addFile("data.swf"); //will be loaded into the specified defaultLoaderContext
```

Be aware that this doesn't work for the SWF loaded as binary. Those data is loaded in the default LoaderContext of the method loadBytes of the Loader object.
```
var ctx:LoaderContext = new LoaderContext(false, new ApplicationDomain());
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.loadableFileFactory.defaultLoaderContext = ctx;

//...
var file:ILoadableFile = cml.addFile("data.swf", LoadableFileType.BINARY);

//...
var ldr:Loader = file.getData("flash.display.Loader"); //into the default LoaderContext of the Loader.loadBytes method
```

## Custom LoaderContext for SWF files loaded as binary ##

You just need to do a specific class to do that :
```
package ch.demo
{
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;

	public class SpecificContextLoader extends Loader
	{
		public override function loadBytes(url:URLRequest, context:LoaderContext=null):void
		{
			if (context == null) context = new LoaderContext(false, new ApplicationDomain());
			super.loadBytes(url, context);
		}
	}
}
```

Then, just use it when you use the getData method :
```
var ctx:LoaderContext = new LoaderContext(false, new ApplicationDomain());
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.loadableFileFactory.defaultLoaderContext = ctx;

//...
var file:ILoadableFile = cml.addFile("data.swf", LoadableFileType.BINARY);

//...
var ldr:Loader = file.getData("ch.demo.SpecificContextLoader");
```

You can also use the easiest way :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var file:ILoadableFile = cml.addFile("data.swf", LoadableFileType.BINARY);

//...
var data:ByteArray = file.getData();
var ldr:Loader = new Loader();
ldr.loadBytes(data, new LoaderContext(false, new ApplicationDomain());
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)