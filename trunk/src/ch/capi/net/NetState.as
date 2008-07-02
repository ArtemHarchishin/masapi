package ch.capi.net
{
	
	import flash.system.Security;
	
	/**
	 * Represents a state of a file. The file can be online, offline or this state
	 * can be retrived dynamically.
	 * 
	 * @see			ch.capi.net.INetStateManager	INetStateManager
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.1
	 */
	public class NetState
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Defines the online state.
		 */
		public static const ONLINE:String = "online";
		
		/**
		 * Defines the offline state.
		 */
		public static const OFFLINE:String = "offline";
		
		/**
		 * Defines the dynamic state.
		 */
		public static const DYNAMIC:String = "dynamic";
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Retrieves the current <code>NetState</code> constant based on the current
		 * <code>Security.sandboxType</code>.
		 * 
		 * @return	<code>NetState.ONLINE</code>, <code>NetState.OFFLINE</code> or <code>NetState.DYNAMIC</code>.
		 */
		public static function get():String
		{
			var s:String = Security.sandboxType;
			switch(s)
			{
				case Security.REMOTE :
					return ONLINE;
					
				case Security.LOCAL_TRUSTED:
				case Security.LOCAL_WITH_FILE:
					return OFFLINE;
					
				case Security.LOCAL_WITH_NETWORK:
				default:
					return DYNAMIC;
			}
		}
	}
}