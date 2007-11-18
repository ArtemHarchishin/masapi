package ch.capi.data
{
	/**
	 * Represents a FIFO list.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface IQueue extends IDataStructure, IList
	{
		/**
		 * Get the first element of the <code>IQueue</code>.
		 * 
		 * @return	The first element.
		 */
		function getFirstElement():*;
		
		/**
		 * Get the last element of the <code>IQueue</code>.
		 * 
		 * @return	The last element.
		 */
		function getLastElement():*;
	}
}