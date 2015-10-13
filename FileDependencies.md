# How to manage the file dependencies #

The probably most important feature of masapi is that it can manage the dependencies within the files.

When you are programming a complex web site and with a lot of pages, probably each of those will need some other data to be downloaded (xml, txt, ...). The most of the time, developers begins to load the page and that one will load the necessary content afterwards, letting the visitor wait (probably without showing something is currently loaded). That's what we call a File dependency : a file that need other ones to work correctly.

Masapi can internally manage those dependencies for you. It is very easy to use and can be mapped to any site/application architecture !

## Preparing ##

To explain how masapi works, the sample page loaded by masapi will use this architecture :

![http://masapi.googlecode.com/svn/wiki/sampleDependency.png](http://masapi.googlecode.com/svn/wiki/sampleDependency.png)

That page (just call it 'astorm') will be loaded by anoter SWF ('index.swf' in the samples).

## Configuration ##

In order to tell masapi about the file dependencies, you need to define a XML that represents your current architecture. That file is very simple : first you list all the files contained into your site and then you explain the dependencies.

For the current case, the XML configuration file will look like this :
```
<?xml version="1.0" encoding="utf-8" ?>
<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:noNamespaceSchemaLocation="http://www.astorm.ch/masapi/masapiFileDependencies.xsd">
        <files>
                <file name="astorm"     url="astorm.swf"     type="swf" />
                <file name="font"       url="font.swf"       type="swf" />
                <file name="background" url="storm.jpg"      type="swf" />
                <file name="text"       url="text.txt"       type="text" />
                <file name="animation"  url="textAnim.swf"   type="binary" />
        </files>
        <dependencies>
                <dependency name="astorm">
                        <file name="background" />
                        <file name="animation" />
                </dependency>
                <dependency name="animation">
                        <file name="text" />
                        <file name="font" />
                </dependency>
        </dependencies>
</application>
```

The XMLSchema definition can be found [here](http://www.astorm.ch/masapi/masapiFileDependencies.xsd). This is not required for masapi, but it will give you a way to check that your XML structure is correct for the masapi's parser. You can use this [validator](http://www.astorm.ch/masapi/validator.php) to check if your XML is valid.

### File listing ###

Each 'file' node represents a file into your web site. The file node have three mandatory attributes :
  * name : A unique name representing the file.
  * url : The url (relative or absolute).
  * type : The type (extracted from the LoadableFileType constants). It can be one of the following : swf,text,variables,binary,sound,stream.

You can also add specific values into the attributes :
  * virtualBytesTotal : The virtual bytes total is an integer value that will help masapi to manage the overall progress (see ILoadableFile.virtualTotalBytes).
  * global : A boolean value (false by default) indicating that the specified file is required everywhere and that there is no need to specify it as dependency.
  * useCache : A boolean value (true by default) indicating that the specified file must be reloaded each time needed.

Note that you can other attributes that will be added to the 'properties' attribute of the ILoadableFile (see below).

```
<file name="astorm"     url="astorm.swf"     type="swf" />
<file name="demo"       url="myFile.php"     type="variables"      global="true"      useCache="false" />
```

You can also see that the 'animation' file will be loaded as binary data (using URLLoader) instead of swf (using Loader). That will prevent the textAnim.swf to be played before the astorm page will be loaded.

### Dependencies listing ###

Creating a dependency is very easy : first you create a 'dependency' node that will tell to masapi the specified file (attribute 'name') will need that all files specified into the subnodes have to been loaded.

For example into the following node, the files named 'text' and 'font' will have to be loaded before masapi begins the loading of the 'animation' file :
```
<dependency name="animation">
		<file name="text" />
		<file name="font" />
</dependency>
```

Any other attributes added to that nodes will be ignored by the parser.

## Load the dependencies ##

Once the configuration file is complete, you need to manually load it and give him to the masapi's parser :
```
import ch.capi.core.*;

//load the configuration file
var configLoader:URLLoader = new URLLoader();
configLoader.dataFormat = URLLoaderDataFormat.TEXT;
configLoader.addEventListener(Event.COMPLETE, onConfigurationLoaded);
configLoader.load(new URLRequest("configuration.xml"));

function onConfigurationLoaded(evt:Event):void
{
	//retrieve the XML document
	var xmlConfig:XMLDocument = new XMLDocument();
	xmlConfig.ignoreWhite = true;
	xmlConfig.parseXML(configLoader.data);
	
	//parse the configuration file to masapi
	parseConfigurationFile(xmlConfig);
}

function parseConfigurationFile(config:XMLDocument):void
{
	//parse the configuration
	var parser:ApplicationFileParser = new ApplicationFileParser();
	parser.parse(config.firstChild);
}
```

The ApplicationFileParser will directly parse the files into the ApplicationFile class. Once the 'parse' method has been called, the files are ready to be use !

## Load a file that requires dependencies ##

Using the sample above, you can now launch the loading of the 'astorm' file. That becomes really easy :

```
import ch.capi.core.*;

//retrieve the page application file
var pageToLoad:ApplicationFile = ApplicationFile.getFile("astorm");

//create the massloader
var massLoader:ApplicationMassLoader = new ApplicationMassLoader();

//add the page to load. That's the important line :)
massLoader.addApplicationFile(pageToLoad);

//launch !
massLoader.start();
```

When you call the 'addApplicationFile' method, masapi will automatically add all the dependencies need by the specified file at the right priority.

### How does masapi load dependencies ###

Keeping the sample, masapi will work like that :

![http://masapi.googlecode.com/svn/wiki/sampleDependencySteps.png](http://masapi.googlecode.com/svn/wiki/sampleDependencySteps.png)

  1. Step 1 : masapi will load the 'font' and 'text' that are needed for the 'animation' file.
  1. Step 2 : masapi will load the 'animation' and 'background' files needed for the 'astorm' page.
  1. Step 3 : all the needed files are loaded, masapi will load the 'astorm' page.


## Using the files ##

It is very easy to use the files specified into the configuration. Simply call the 'ApplicationFile.getFile' method :
```
import ch.capi.core.*;

var animationFile:ApplicationFile = ApplicationFile.getFile("animation");
var ldr:Loader = animationFile.getData("flash.display.Loader");
addChild(ldr);
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)