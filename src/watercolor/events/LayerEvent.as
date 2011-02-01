package watercolor.events
{

	import flash.events.Event;

	import watercolor.commands.vo.CommandVO;
	import watercolor.elements.Layer;
	import watercolor.elements.components.Workarea;
	import watercolor.models.vo.LayerPropertiesVO;


	/**
	 * Layer Events.
	 *
	 * @author Sean Thayne.
	 */
	public class LayerEvent extends Event
	{
		/**
		 * Event for when a Layer is being added.
		 */
		public static const ADD:String = "addLayer";


		/**
		 * Event for when a Layer is being removed.
		 */
		public static const REMOVE:String = "removeLayer";


		/**
		 * Event for when a Layer's position is being changed.
		 */
		public static const POSITION_CHANGE:String = "setLayerOrder";


		/**
		 * Event for when a Layer's properties are being changed.
		 */
		public static const PROPERTY_CHANGE:String = "changeLayer";


		/**
		 * Worearea to add layer to.
		 */
		public var workArea:Workarea;


		/**
		 * Layer being manipulated.
		 */
		public var layer:Layer;


		/**
		 * New Index for
		 */
		public var newPositionIndex:uint;


		/**
		 * Layer Properties being applied.
		 */
		public var newLayerProperties:LayerPropertiesVO;


		public function LayerEvent( type:String, layer:Layer, workArea:Workarea = null, newLayerProperties:LayerPropertiesVO = null, newPositionIndex:int = 0 )
		{
			this.layer = layer;
			this.workArea = workArea;
			this.newPositionIndex = newPositionIndex;
			this.newLayerProperties = newLayerProperties;

			super( type, false, false );
		}

	}
}