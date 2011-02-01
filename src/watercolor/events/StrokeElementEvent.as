package watercolor.events
{
	import flash.events.Event;
	
	import mx.graphics.IStroke;
	
	import watercolor.elements.interfaces.IElementGraphic;


	/**
	 * 
	 * @author mediarain
	 */
	public class StrokeElementEvent extends Event
	{

		/**
		 * Event to dispatch for putting a stroke on some elements
		 * @default 
		 */
		public static const STROKE:String = "eventStrokeElement";


		/**
		 * Event to dispatch once the elements have been stroked
		 * @default 
		 */
		public static const STROKED:String = "eventElementStroked";


		/**
		 *
		 * The list of Elements that we want to stroke
		 */
		public var elements:Vector.<IElementGraphic>;	
		/**
		 * 
		 * @default 
		 */
		public var stroke:IStroke;
		
		/**
		 * 
		 * @param type
		 * @param elements
		 * @param stroke
		 */
		public function StrokeElementEvent( type:String, elements:Vector.<IElementGraphic>, stroke:IStroke )
		{
			this.elements = elements;
			this.stroke = stroke;
			
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new StrokeElementEvent( this.type, this.elements, this.stroke );
		}
	}
}