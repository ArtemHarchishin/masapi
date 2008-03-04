This sample shows how you can dynamically retrieve the ILoadableFile source into the loaded swf.

The point is simply to do a document class that inherits from ch.capi.display.AbstractDocument and override the initializeContext
method. The other way is to implement the ch.capi.core.IApplicationContext and its method. The MassLoader will automatically detect
it and call the initializeContext method with the ILoadableFile source that has been used to load the swf.