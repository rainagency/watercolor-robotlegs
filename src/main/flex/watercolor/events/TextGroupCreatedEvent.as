package watercolor.events
{
	import flash.events.Event;
	
	import watercolor.elements.TextGroup;

	/**
	 * Create Text Group Event
	 * @author mediarain
	 */
	public class TextGroupCreatedEvent extends Event
	{
		
		/**
		 * 
		 * @default 
		 */
		public static const TEXT_GROUP_CREATED:String = "eventTextGroupCreated";
		
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
		public function TextGroupCreatedEvent( type:String, textGroup:TextGroup )
		{
			this.textGroup = textGroup;
			super( type, true, true );
		}

		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new TextGroupCreatedEvent( this.type, this.textGroup );
		}
	}
}