package watercolor.events
{
	import flash.events.Event;
	
	import watercolor.elements.TextGroup;
	import watercolor.elements.interfaces.ITextGroup;

	/**
	 * Event for updating a text group
	 * @author mediarain
	 */
	public class UpdateTextGroupEvent extends Event
	{
		/**
		 *
		 * Events
		 */
		public static const UPDATE_SCALE:String = "eventUpdateScale";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_SPACE:String = "eventUpdateSpace";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_SPACING_METHOD:String = "eventUpdateSpacingMethod";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_DIRECTION:String = "eventUpdateDirection";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_VERTICAL_ALIGN:String = "eventUpdateVerticalAlign";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_HORIZONTAL_ALIGN:String = "eventUpdateHorizontalAlign";
		/**
		 * 
		 * @default 
		 */
		public static const UPDATE_ADAPTER:String = "eventUpdateAdapter";
		
		/**
		 * 
		 * @default 
		 */
		public var textGroups:Vector.<TextGroup>;
		
		/**
		 * 
		 * @default 
		 */
		public var value:String;
		
		/**
		 * 
		 * @default 
		 */
		public var adapter:ITextGroup;
				
		/**
		 * 
		 * @param type
		 * @param textGroup
		 * @param value
		 * @param adapter
		 */
		public function UpdateTextGroupEvent( type:String, textGroups:Vector.<TextGroup>, value:String = "", adapter:ITextGroup = null )
		{
			this.textGroups = textGroups;
			this.value = value;
			this.adapter = adapter;
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new UpdateTextGroupEvent( this.type, this.textGroups, this.value, this.adapter );
		}
	}
}