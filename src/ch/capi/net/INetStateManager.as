package ch.capi.net
{
	/**
	 * Represents an object that can manages his state over
	 * the Internet.
	 * 
	 * @see			ch.capi.net.NetState	NetState
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface INetStateManager
	{
		/**
		 * Defines the <code>NetState</code> value. The value available can
		 * be retrieved from the <code>NetState</code> class.
		 * 
		 * @see		ch.capi.net.NetState	NetState
		 * @see		#isOnline()				isOnline()
		 */
		function get netState():String;
		function set netState(value:String):void;
		
		/**
		 * Retrieves the state depending of the <code>NetState</code>
		 * value defined.
		 * <p>If the <code>netState</code> value is <code>NetState.ONLINE</code>, then this
		 * method returns <code>true</code>. If the <code>netState</code> value is <code>NetState.OFFLINE</code>,
		 * then this method returns <code>false</code>. If the <code>netState</code> value is
		 * <code>NetState.DYNAMIC</code>, then this method will try to retrieves dynamically the state
		 * of the <code>INetStateManager</code>.</p>
		 * 
		 * @return	<code>true</code> if the <code>INetStateManager</code> is online or not.
		 * @see		#netState	Define the online state
		 */
		function isOnline():Boolean;
	}
}