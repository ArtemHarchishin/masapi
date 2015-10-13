# Masapi Overall Progression #

In order to provide an interessting value for the IMassLoader.bytesTotal property before the loading has begun, masapi uses the virtualBytesTotal property of a ILoadableFile. A ILoadableFile works like that :
  * if the bytesTotal value isn't known, then the virtualBytesTotal property is used to provide de ILoadableFile.bytesTotal.
  * as soon as the real bytesTotal value is used, then this one is used to provide the ILoadableFile.bytesTotal.

This kind of management can do strange behavior of the size of the loaded files are greather than the specified virtualBytesTotal. You will find two demos [here](http://www.astorm.ch/blog/index.php?post/2008/06/11/Masapi-overall-progression) (fr) about that.

## Dealing with virtualBytesTotal ##

By default, when a ILoadableFile is created by the LoadableFileFactory, his size is 200ko.
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var file1:ILoadableFile = cml.addFile("myFile.txt");
var file2:ILoadableFile = cml.addFile("otherFile.swf");

trace(file1.bytesTotal); //about 200ko
trace(file2.bytesTotal); //about 200ko too
```

What happen with the following code :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.massLoader.parallelFiles = 1;
cml.massLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);

cml.addFile("myFile.txt");
cml.addFile("otherFile.swf");

cml.start();

function onProgress(evt:ProgressEvent):void
{
	trace(cml.massLoader.loadInfo.percentLoaded);
}
```

The following behaviors can be following :
  * if the real size of both file size are under 200ko, then the percentage will grow slowlier than the real progression and when the real size of the files will be know, it will jump to the good value.
  * if the real size of one of the files (or both) are greater than 200ko, then the percentage will grow faster than the real progression and when the real size of the files will be know, it will go backward to the good value.

Knowing that, it's simple to adjust the values of the virtualBytesTotal property in order that the virtualBytesTotal is bigger than the real bytesTotal, but not too much :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var file1:ILoadableFile = cml.addFile("myFile.txt"); //9ko
var file2:ILoadableFile = cml.addFile("otherFile.swf"); //545ko

file1.virtualBytesTotal = 10*1000; //about 10ko
file2.virtualBytesTotal = 600*1000; //about 600ko

trace(file1.bytesTotal); //about 10ko
trace(file2.bytesTotal); //about 600ko
```

As you can see here, the differences between virtualBytesTotal (10 - 600) and the real bytes (9 - 545) are small, so the progression will be fluid. The most important is that the virtualBytesTotal is greather than the real bytes total !

If you don't know the size of your file, just put a big value into the virtualBytesTotal (such as 5Mo) and as soon as the real total bytes are know, masapi will readjust the values.

## Default virtualBytesTotal (LoadableFileFactory) ##

If you have a lot of files that are bigger than 200ko, just tell the LoadableFileFactory about it !
```
var cml:CompositeMassLoader = new CompositeMassLoader();
cml.loadableFileFactory.defaultVirtualBytesTotal = 500*1000; //500ko by default

var file1:ILoadableFile = cml.addFile("myFile.txt");
var file2:ILoadableFile = cml.addFile("otherFile.swf");
//...
```

## Default virtualBytesTotal (file dependencies) ##

If you're using the [file dependencies](http://code.google.com/p/masapi/wiki/FileDependencies), then it is very easy to deal with the virtualBytesTotal. Just put it into your XML configuration :
```
<?xml version="1.0" encoding="utf-8" ?>
<application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:noNamespaceSchemaLocation="http://www.astorm.ch/masapi/masapiFileDependencies.xsd">
        <files virtualBytesTotal="500000"> <!-- 500ko by default -->
                <file name="astorm"     url="astorm.swf"     type="swf" />
                <file name="font"       url="font.swf"       type="swf" />
                <file name="background" url="storm.jpg"      type="swf" />
                <file name="text"       url="text.txt"       type="text" />
                <file name="animation"  url="textAnim.swf"   type="binary" virtualBytesTotal="700000" /> <!-- 700ko by default for this file -->
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

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)