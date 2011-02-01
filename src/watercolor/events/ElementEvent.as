package watercolor.events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import watercolor.commands.vo.CommandVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.Element;
	import watercolor.elements.interfaces.IElementContainer;


	/**
	 * Element Events
	 *
	 * @author Sean Thayne
	 */
	public class ElementEvent extends Event
	{

		/**
		 * Event for when a element is being added.
		 */
		public static const ADD:String = "waterColorElementAdd";


		/**
		 * Event for when a element is being removed.
		 */
		public static const REMOVE:String = "waterColorElementRemove";

		/**
		 * Event for when a element's position is being changed.
		 */
		public static const POSITION_CHANGE:String = "waterColorElementPositionChange";


		/**
		 * Event for after a element's position has changed.
		 */
		public static const POSITION_CHANGED:String = "waterColorElementPositionChanged";


		/**
		 * Event for when a element's transform matrix is changing.
		 */
		public static const TRANSFORM:String = "waterColorElementTransform";


		/**
		 * Event for after a element's transform matrix has changed.
		 */
		public static const TRANSFORM_COMPLETE:String = "waterColorElementTransformComplete";


		/**
		 *
		 * The command VO that is sent in the event
		 */
		public var elements:Vector.<Element>;


		/**
		 * Parent element
		 */
		public var parent:IElementContainer;


		/**
		 * Arrange Direction.
		 *
		 * @see watercolor.type.ArrangeDirectionType
		 */
		public var direction:String;
		
		/**
		 * Optional position for placement on the work area
		 * This point must be relative to the parent specified in this event
		 * 
		 */ 
		public var position:Point;


		/**
		 *
		 * The command VO that is sent in the event.
		 *
		 * This can be any raw WaterColor command you want executed.
		 */
		public var commandVO:CommandVO;


		/**
		 * Constructor
		 * @param type
		 * @param commandVO
		 */
		public function ElementEvent( type:String, elements:Vector.<Element> = null, parent:IElementContainer = null, commandVO:CommandVO = null, direction:String = null, position:Point = null )
		{
			this.elements = elements;
			this.parent = parent;
			this.commandVO = commandVO;
			this.direction = direction;
			this.position = position;

			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new ElementEvent( this.type );
		}
	}
}