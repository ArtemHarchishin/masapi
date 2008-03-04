package ch.capi.data
{
	/**
	 * Represents a LIFO list.
	 * 
	 * @author		Cedric Tabin - thecaptain
	 * @version		1.0
	 */
	public interface IStack extends IDataStructure, IList
	{
		/**
		 * Get the top element of the <code>IStack</code>.
		 * 
		 * @return	The top element.
		 */
		function getTopElement():*;
	}
}