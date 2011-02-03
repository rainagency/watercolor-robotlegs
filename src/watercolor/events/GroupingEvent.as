package watercolor.events
{
	import flash.events.Event;

	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	import watercolor.elements.Element;
	import watercolor.elements.interfaces.IElementContainer;


	/**
	 *
	 * @author mediarain
	 */
	public class GroupingEvent extends Event
	{
		/**
		 *
		 * Events for grouping items
		 */
		public static const GROUP:String = "eventGroup"; // dispatched for grouping some items


		/**
		 *
		 * @default
		 */
		public static const UNGROUP:String = "eventUnIsolate"; // dispatched for un-grouping some items


		/**
		 *
		 * @default
		 */
		public var parent:IElementContainer;


		/**
		 *
		 * @default
		 */
		public var elements:Vector.<Element>;


		/**
		 * Constructor
		 * @param type
		 * @param parent
		 * @param elements
		 */
		public function GroupingEvent( type:String, parent:IElementContainer, elements:Vector.<Element> )
		{
			this.parent = parent;
			this.elements = elements;
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new GroupingEvent( this.type, this.parent, this.elements );
		}
	}
}