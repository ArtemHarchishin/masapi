package ch.capi.net
{
	import flash.net.URLRequest;
	
	/**
	 * Selector for the creation of an <code>ILoadableFile</code> into a 
	 * <code>LoadableFileFactory</code>.
	 * 
	 * @see			ch.capi.net.LoadableFileFactory		LoadableFileFactory
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface ILoadableFileSelector
	{
		/**
		 * Creates a <code>ILoadableFile</code> using the specified <code>LoadableFileFactory</code>. A
		 * <code>ILoadableFileSelector</code> should't use the <code>create()</code> or <code>createFile()</code> methods
		 * of the <code>LoadableFileFactory</code> because this method will be called again (risk of recursivity error).
		 * 
		 * @param	request		The <code>URLRequest</code>.
		 * @param	factory		The <code>LoadableFileFactory</code>.
		 * @return	The created <code>ILoadableFile</code> object.
		 */
		function create(request:URLRequest, factory:LoadableFileFactory):ILoadableFile;
	}
}