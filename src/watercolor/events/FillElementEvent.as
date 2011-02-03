package watercolor.events
{
	import flash.events.Event;
	
	import mx.graphics.IFill;
	
	import watercolor.elements.interfaces.IElementGraphic;


	/**
	 * 
	 * @author mediarain
	 */
	public class FillElementEvent extends Event
	{

		/**
		 * Event to dispatch for filling in elements
		 * @default 
		 */
		public static const FILL:String = "eventFillElement";


		/**
		 * Event to dispatch once the elements have been filled
		 * @default 
		 */
		public static const FILLED:String = "eventElementFilled";


		/**
		 *
		 * The list of Elements that we want to fill
		 */
		public var elements:Vector.<IElementGraphic>;	
		/**
		 * 
		 * @default 
		 */
		public var fill:IFill;
		
		/**
		 * 
		 * @param type
		 * @param elements
		 * @param fill
		 */
		public function FillElementEvent( type:String, elements:Vector.<IElementGraphic>, fill:IFill )
		{
			this.elements = elements;
			this.fill = fill;
			
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new FillElementEvent( this.type, this.elements, this.fill );
		}
	}
}