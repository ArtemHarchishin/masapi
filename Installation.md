# Masapi Installation #

This short page is a step by step guide to install masapi.

## Download ##

First step, you need to download the [latest release](http://code.google.com/p/masapi/downloads/list) of Masapi. This package is a all-in-one package and contains the sources, the [API reference](http://www.astorm.ch/masapi/doc) and the samples.

You can find other bundles [here](http://masapi.googlecode.com/svn/trunk/bundles/).

## Installation ##

The second step you need to have the 'ch' folder into the classpath of your project. There are two ways in flash to do that :
  * put the 'ch' folder in the same place as your FLA.
  * add the 'src' folder into your classpath (File > Publish settings > Flash > ActionScript 3 settings).

## Test ##

Just open your FLA (with the right classpath) and try this sample code :
```
import ch.capi.net.*;
import ch.capi.events.*;

var ml:MassLoader = new MassLoader();
ml.addEventListener(MassLoadEvent.FILE_OPEN, onFileOpen);

function onFileOpen(evt:MassLoadEvent):void { trace("open"); }
```

If it works correctly, then your installation is well done !

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)