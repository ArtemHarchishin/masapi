# Extend the supported load managers #

By default, masapi supporte the following load managers :
  * Loader
  * URLLoader
  * URLStream
  * Sound

In some applications, it may be possible that those basic supported load managers aren't sufficient and you'll need to define your personal one. Even if there is no direct way to do that, it is not so hard to extend masapi to new load managers !

There are the main steps to do that :
  * Define the ILoadableFile implementation
  * Extend the LoadableFileFactory
  * (and maybe extend the ExtensionFileSelector)

## Create a ILoadableFile implementation ##

To define a new ILoadableFile, you just need to create a class and implement the ch.capi.net.ILoadableFile interface. In order to avoid recoding the basic functionnalities, that class can also extends the ch.capi.net.AbstractLoadableFile class.

Here is a basic example, using a Loader :
```
package
{
	import ch.capi.net.*;
	
	public class MyLoadableFile extends AbstractLoadableFile implements ILoadableFile
	{
		public function MyLoadableFile(loadObject:Loader):void
		{
			super(loadObject);
			
			var dispatcher:IEventDispatcher = getEventDispatcher();
			registerTo(dispatcher); //into the AbstractLoadableFile. Needed !
		}
		
		public function getEventDispatcher():IEventDispatcher { return (loadManagerObject as Loader).contentLoaderInfo; }
		public function isClassSupported(type:String):Boolean {	return type == "flash.display.Loader"; 	}
		public function getType():String {	return LoadableFileType.SWF; }
		public function getEventDispatcher():IEventDispatcher { return (loadManagerObject as Loader).contentLoaderInfo; }
		
		public function getData(asClass:String=null):*
		{
			if (asClass != null && !isClassSupported(asClass)) throw new ArgumentError("The type '"+asClass+"' is not supported");	
			return (loadManagerObject as Loader);
		}
		
		public override function start():void
		{
			super.start();
			
			var re:URLRequest = getURLRequest(); //into the AbstractLoadableFile
			var ul:Loader = loadManagerObject as Loader;
			ul.load(re, loaderContext);
		}
	}
}
```

Note that a call to the registerTo method is really important because otherwise the AbstractLoadableFile class will not be able to handle the events and redirect them.


## Update the Factory ##

The best way to do that is simply to extend the LoadableFileFactory :
```
package
{
	import ch.capi.net.*;

	public class MyFileFactory extends LoadableFileFactory
	{
		public function createMyLoadableFile(request:URLRequest=null):ILoadableFile
		{
			var ldr:Loader = new Loader();
			var myLoadableFile:MyLoadableFile = new MyLoadableFile(ldr);
			myLoadableFile.urlRequest = request;
			
			return myLoadableFile;
		}
	}
}
```

At this step, you can already work with your factory. The only problem that left is that the swf files by default will use the other method (createLoader).

Note that to solve this issue, it would be easier to override the createLoader method !

## Extend the file selector ##

The basic way masapi uses to choice the type of the file is based on the extension. You can define your own implementation of a ILoadableFileSelector, but in that case, we will simple extends the default ExtensionFileSelector.

```
package
{
	import ch.capi.net.*;

	public class MyExtensionSelector extends ExtensionFileSelector
	{
		public function override create(request:URLRequest, factory:LoadableFileFactory):ILoadableFile
		{
			if (factory is MyFileFactory)
			{
				var extension:String = getExtension(request);
				var type:String = extensions.getValue(extension); //retrieve the type
				
				if (type == LoadableFileType.SWF)
				{
					var myFactory:MyFileFactory = factory as myFileFactory;
					return myFactory.createMyLoadableFile(request);
				}
			}
			
			return super.create(request, factory);
		}
	}
}
```

And now you can simply use all that stuff :
```
var mySelector:MyExtensionSelector = new MyExtensionSelector();
var myFactory:MyFileFactory = new MyFileFactory(mySelector);
var cml:CompositeMassLoader = new CompositeMassLoader(false, myFactory);

var file:ILoadableFile = cml.addFile("file.swf"); //will use a MyLoadableFile instance
//...
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)