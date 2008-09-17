This sample is based on the sample 1.0 (Basic massloader)

This sample shows the use of the loading policy. The loading policy allows you to specify how many times a file must be reloaded
before being aborted or to load a default file.

In this sample the default implementation of the loading policy is used (DefaultLoadPolicy). By default, the MassLoader will try to
load the non existent xml file 3 times and then it will load the default xml file specified.