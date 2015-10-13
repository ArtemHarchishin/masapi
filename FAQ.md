# Frequently asked questions #

There is a list of frequently asked questions. [Participate](http://groups.google.com/group/masapi) !

  1. What about the API compatibility ?
  1. What's the size of the API ?
  1. How can I ask about features, updates, report bugs, ... ?
  1. What are the constraints of the LGPL ?
  1. Is there a spec for the file dependencies XML ?
  1. How can I reload a File ?
  1. If a file fails to load, masapi try to reload it. Why ?
  1. How to know if a file has been successfully downloaded or not ?
  1. My download starts only after a lot amount of percentage. Why ?


## 1. What about the API compatiblity ? ##
This is a full AS3 API (unusable in AS2). It is fully compatible with Flex, Flash and AIR. There my be some unsupported load managers but you can [add them](http://code.google.com/p/masapi/wiki/ExtendSupportedLoadManagers).

## 2. What's the size of the API ? ##
If you use all the features of masapi, the size of the SWF will be about 17ko. If you use only the CompositeMassLoader, then it will approach 13ko. If you use only the ApplicationMassLoader, then it will be less than 11ko.

## 3. How can I ask about features, updates, report bugs, ... ? ##
Just come on the [Google group](http://groups.google.com/group/masapi) :)

## 4. What are the constraints of the LGPL ? ##
None. You can use masapi in any project you want ! A [feedback](http://groups.google.com/group/masapi) would be very appreciated.

## 5. Is there a spec for the file dependencies XML ? ##
Yes. There is this [validator](http://www.astorm.ch/masapi/validator.php).

## 6. How can I reload a File ? ##
Just re-call the start method on the ILoadableFile. If the useCache attribute is set to false, then the file will be reloaded.

## 7. If a file fails to load, masapi try to reload it. Why ? ##
That's the default behavior of the LoadPolicy contained into a MassLoader. If you want to avoid it, just take a look to the [loading policy](http://code.google.com/p/masapi/wiki/LoadingPolicy) wiki page.

## 8. How to know if a file has been successfully downloaded or not ? ##
Just take a look at this page : [How to handle the download errors](http://code.google.com/p/masapi/wiki/ErrorsHandling)

## 9. My download starts only after a lot amount of percentage. Why ? ##
The default behavior of the MassLoader is to wait that the specified number of parallelFiles are open before dispatching the first ProgressEvent. If there are many files to load, it can take a lot of time before all the files are open. To avoid that, you can simple put the alwaysDispatchProgressEvent property of MassLoader to true.

[Back to the user guide](http://code.google.com/p/masapi/wiki/UserGuide)