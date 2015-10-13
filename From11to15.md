# From masapi 1.1 to masapi 1.5 #

Don't worry, the masapi 1.5 version is 99% compatible with masapi 1.1 !

## Things that you MUST update ##

The only incompatible update is the class ch.capi.core.IApplicationContext that doesn't exist anymore. If you were using this interface, you must now implement the ch.capi.display.IRootDocument. The methods to implement are the same, so there is no other change to do !

## Things that have been updated ##

Here are the main updates for this new version :
  * You have now advanced progression information (see IMassLoader.loadInfo property or ILoadInfo interface).
  * The data can be dynamically transformed by a ILoadableFile/ApplicationFile ( getData(aClassName) ).
  * The LoadableFileFactory now supports a default LoaderContext and a default SoundLoaderContext.
  * There is no more need to keep references on the created ILoadableFile if you use a CompositeMassLoader.
  * A ILoadManager stores its close Event (so you can know its final state).
  * The management of the ILoadPolicy has been improved (see DefaultLoadPolicy).
  * About the ApplicationFile, they are now created into an ApplicationContext, that lets you have some files to have the same name.
  * The ApplicationFile parser has been improved. You can now have an XML listing your files and another listing your dependencies.
  * There is an [online validator](http://www.astorm.ch/masapi/validator.php) to check your XML dependency.
  * The ch.capi.data API has been cleaned (more lightweight API).
  * Some minor bugs have been corrected.

## Stay tuned ##

There is the [Google group](http://groups.google.com/group/masapi) ! :)