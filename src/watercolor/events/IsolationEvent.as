package watercolor.events
{
	import flash.events.Event;

	import watercolor.elements.Element;


	/**
	 *
	 * @author mediarain
	 */
	public class IsolationEvent extends Event
	{
		/**
		 *
		 * Events for isolating items
		 */
		public static const ISOLATE:String = "eventIsolate"; // dispatched for isolating an item


		public static const UNISOLATE:String = "eventUnIsolate"; // dispatched for un-isolating an item


		public var element:Element;


		/**
		 * Constructor
		 * @param type
		 * @param commandVO
		 */
		public function IsolationEvent( type:String, element:Element = null )
		{
			this.element = element;
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new IsolationEvent( this.type, this.element );
		}
	}
}