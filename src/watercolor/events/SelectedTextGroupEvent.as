package watercolor.events
{
	import flash.events.Event;
	
	import watercolor.elements.TextGroup;

	/**
	 * Event to indicate that a text group has been selected
	 * @author mediarain
	 */
	public class SelectedTextGroupEvent extends Event
	{
		/**
		 *
		 * Events
		 */
		public static const TEXT_GROUP_SELECTED:String = "eventTextGroupSelected";
		
		public static const TEXT_GROUP_UNSELECTED:String = "eventTextGroupUnSelected";
		
		/**
		 * 
		 * @default 
		 */
		public var textGroup:TextGroup;
		
		/**
		 * 
		 * @param type
		 * @param textGroup
		 */
		public function SelectedTextGroupEvent( type:String, textGroup:TextGroup )
		{
			this.textGroup = textGroup
			super( type, true, true );
		}

		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new SelectedTextGroupEvent( this.type, this.textGroup );
		}
	}
}