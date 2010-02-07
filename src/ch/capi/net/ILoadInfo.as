package ch.capi.net 
{
	/**
	 * Contains a lot of information about a massive loading.
	 * 
	 * @author	Cédric Tabin - thecaptain
	 * @version 1.0
	 */
	public interface ILoadInfo 
	{
		/**
		 * Defines the <code>IMassLoader</code> source.
		 */
		function get massLoader():IMassLoader;
		
		/**
		 * Defines the bytes that have been loaded.
		 */
		function get bytesLoaded():uint;
		
		/**
		 * Defines the total bytes to load.
		 */
		function get bytesTotal():uint;
		
		/**
		 * Defines the number of bytes to load.
		 */
		function get bytesRemaining():uint;
		
		/**
		 * Defines the elapsed time since the loading as begun.
		 */
		function get elapsedTime():uint;
		
		/**
		 * Defines the remaining time, based on the speed and the bytes that left to be loaded.
		 * If the current speed is zero, this value will be -1.
		 */
		function get remainingTime():int;
		
		/**
		 * Defines the current speed of the download (kilobytes per seconds).
		 */
		function get currentSpeed():Number;
		
		/**
		 * Defines the average speed since the loading has begun.
		 */
		function get averageSpeed():Number;
		
		/**
		 * Defines a Number between 0 and 1 (included) that represents the ratio of the loaded bytes.
		 * @see	#percentLoaded	percentLoaded
		 */
		function get ratioLoaded():Number;
		
		/**
		 * Defines the percent of bytes loaded.
		 * @see	#ratioLoaded	ratioLoaded
		 */
		function get percentLoaded():uint;
		
		/**
		 * Defines the files that have been successfully loaded.
		 */
		function get filesSuccess():Array;
		
		/**
		 * Defines the files that haven't been successfully loaded.
		 */
		function get filesError():Array;
		
		/**
		 * Defines the files that are currently being loaded.
		 */
		function get filesLoading():Array;
		
		/**
		 * Defines the files that currently not being loaded (waits in the loading queue).
		 */
		function get filesIdle():Array;
		
		/**
		 * Reset all the information about the loading.
		 */
		function reset():void;
		
		/**
		 * Update the information about the loading.
		 */
		function update():void;
		
		/**
		 * Represents the data of the <code>ILoadInfo</code> in a <code>String</code>.
		 * 
		 * @return	A <code>String</code> with the useful information.
		 */
		function toString():String;
	}
}
