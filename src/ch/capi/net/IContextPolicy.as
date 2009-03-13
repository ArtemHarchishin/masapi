package ch.capi.net 
{
	import flash.media.SoundLoaderContext;	
	import flash.system.LoaderContext;	
	
	/**
	 * Represents a manager of context for <code>Loader</code> and <code>Sound</code> objects.
	 * 
	 * @see		ch.capi.net.LoadableFileFactory		LoadableFileFactory
	 * @author Cedric Tabin - thecaptain
	 */
	public interface IContextPolicy 
	{
		/**
		 * Retrieves a <code>LoaderContext</code> that will be attached
		 * to the specified <code>ILoadableFile</code>.
		 * 
		 * @param	file				The <code>ILoadableFile</code>.
		 * @param	appDomainPolicy		The policy to retrieve the <code>ApplicationDomain</code>.
		 * @param	secDomainPolicy		The policy to retrieve the <code>SecurityDomain</code>.
		 * @return	The created <code>LoaderContext</code>.
		 * @see		ch.capi.utils.DomainUtils	DomainUtils
		 */
		function getLoaderContext(file:ILoadableFile, appDomainPolicy:String=null, secDomainPolicy:String=null):LoaderContext;
		
		/**
		 * Retrieves a <code>SoundLoaderContext</code> that will be attached
		 * to the specified <code>ILoadableFile</code>.
		 * 
		 * @param	file		The <code>ILoadableFile</code>.
		 * @return	The created <code>SoundLoaderContext</code>.
		 */
		function getSoundContext(file:ILoadableFile):SoundLoaderContext;
	}
}
