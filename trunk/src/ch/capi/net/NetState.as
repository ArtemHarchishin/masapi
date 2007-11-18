package ch.capi.net
{
	/**
	 * Represents a state of a file. The file can be online, offline or this state
	 * can be retrived dynamically.
	 * 
	 * @see			ch.capi.net.INetStateManager	INetStateManager
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
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
	}
}