package watercolor.events
{
	import flash.events.Event;
	
	import watercolor.elements.interfaces.IElementContainer;
	import watercolor.elements.interfaces.ITextGroup;

	/**
	 * Create Text Group Event
	 * @author mediarain
	 */
	public class CreateTextGroupEvent extends Event
	{
		/**
		 * Event for creating a text group
		 * @default 
		 */
		public static const CREATE_TEXT_GROUP:String = "eventCreateTextGroup";
		
		/**
		 * A class that implements the ITextGroup interface
		 * @default 
		 */
		public var adapter:ITextGroup;
		
		/**
		 * The parent where we want to place the text group
		 * @default 
		 */
		public var parent:IElementContainer;
		
		/**
		 * Text to be inserted by default into the TextGroup that is created
		 * @default 
		 */
		public var text:String;
		
		/**
		 * 
		 * @param type
		 * @param adapter
		 * @param parent
		 * @param text default text to insert into TextGroup upon creation
		 */
		public function CreateTextGroupEvent( type:String, parent:IElementContainer, adapter:ITextGroup = null, text:String = "" )
		{
			this.parent = parent;
			this.adapter = adapter;
			this.text = text;
			super( type, true, true );
		}

		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new CreateTextGroupEvent( this.type, this.parent, this.adapter, this.text );
		}
	}
}