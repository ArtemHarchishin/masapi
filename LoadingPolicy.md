# The loading policy #

The target of the loading policy is to define the behavior of masapi when the download of a file fails due to some reasons. Into masapi, that is represented by the ILoadPolicy interface.

## Default behavior ##

By default, when a download fails, masapi will try to reload the file 3 times. After that, won't be considered anymore. That means that the MassLoader will continue to load the other files (by default).

You can easily change that with the following code :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var policy:DefaultLoadPolicy = cml.massLoader.loadPolicy as DefaultLoadPolicy;

policy.reloadTimes = 5; //will try to load 5 times a file before bypassing it
policy.reloadTimes = 0; //will try again and again...
policy.reloadTimes = 1; //won't try to reload the file if it fails

//...
```


## Load another file ##

In some cases, when a loading fails it is useful to load another one instead of the specified one. The DefaultLoadPolicy allows you to do that :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var policy:DefaultLoadPolicy = cml.massLoader.loadPolicy as DefaultLoadPolicy;

var file1:ILoadaleFile = cml.addFile(...);
var replaceFile1:ILoadableFile = cml.loadalbeFileFactory.create(...); //does not add it to the loading queue by default

//if the file1 files, load the replaceFile1
policy.defaultFiles.put(file1, replaceFile1);

//...
```

You can also implement your own loading policy, just by implementing the ILoadPolicy interface and set it to the IMassLoader !


## Stop on failure ##

The default ILoadPolicy allows you to stop the massive loading if a file couldn't be downloaded :
```
var cml:CompositeMassLoader = new CompositeMassLoader();
var policy:DefaultLoadPolicy = cml.massLoader.loadPolicy as DefaultLoadPolicy;
policy.continueOnFailure = false;

//...
```

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)