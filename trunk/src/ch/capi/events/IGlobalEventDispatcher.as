package ch.capi.events 
{
	import flash.events.IEventDispatcher;
		
	/**
	 * Dispatched before an event is dispatched.
	 * 
	 * @eventType	ch.capi.events.GlobalEvent.GLOBAL_BEFORE
	 */
	[Event(name="globalBefore", type="ch.capi.events.GlobalEvent")]
	
	/**
	 * Dispatched after an event is dispatched.
	 * 
	 * @eventType	ch.capi.events.GlobalEvent.GLOBAL_AFTER
	 */
	[Event(name="globalAfter", type="ch.capi.events.GlobalEvent")]
		
	/**
	 * A <code>IGlobalEventDispatcher</code> is a <code>IEventDispatcher</code> that sends
	 * global events before and after any <code>Event</code> is dispatched. This interface
	 * is just a markup to signal which kind of events are dispatched.
	 * 
	 * @author Cedric Tabin - thecaptain
	 */
	public interface IGlobalEventDispatcher extends IEventDispatcher 
	{
	}
}
