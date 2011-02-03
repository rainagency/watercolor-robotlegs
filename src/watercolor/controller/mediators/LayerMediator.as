package watercolor.controller.mediators
{
	import flash.events.Event;
	
	import mx.events.IndexChangedEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.ElementExistenceEvent;
	import spark.events.IndexChangeEvent;
	
	import watercolor.elements.Layer;
	import watercolor.events.LayerElementEvent;
	
	public class LayerMediator extends Mediator
	{
		[Inject]
		public var view:Layer;
		
		/**
		 *
		 */
		public function LayerMediator()
		{
			super();
		}
		
		override public function onRegister():void
		{
			super.onRegister();
			
			view.addEventListener(LayerElementEvent.ADDING_ELEMENT, redispatch);
			view.addEventListener(LayerElementEvent.ADDED_ELEMENT, redispatch);
			view.addEventListener(LayerElementEvent.REMOVING_ELEMENT, redispatch);
			view.addEventListener(LayerElementEvent.REMOVED_ELEMENT, redispatch);
		}
		
		/**
		 * Pre Register event listeners
		 */ 
		override public function preRegister():void
		{
			super.preRegister();
			
			// allows the layer to listen for elements being added even before this layer is added to the stage
			eventMap.mapListener(view, ElementExistenceEvent.ELEMENT_ADD, redispatch);
			eventMap.mapListener(view, ElementExistenceEvent.ELEMENT_REMOVE, redispatch);
		}
		
		protected function redispatch(event:Event):void
		{
			dispatch(event);
		}
	}
}