package watercolor.controller
{
	import org.robotlegs.mvcs.Command;

	import watercolor.commands.vo.ArrangeVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.components.Workarea;
	import watercolor.events.LayerEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	public class ChangeLayerPositionCommand extends Command
	{


		[Inject]
		/**
		 * Event containing command information.
		 */
		public var event:LayerEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;


		/**
		 * Sets the layer's z order within the work area.
		 *
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var arrangeVO:ArrangeVO = new ArrangeVO();
			arrangeVO.originalPosition = event.layer.getPosition();
			arrangeVO.newPosition = arrangeVO.originalPosition.clone();
			arrangeVO.newPosition.index = event.newPositionIndex;
			arrangeVO.element = event.layer;
			
			//Add to history, and execute.
			model.history.addCommand( arrangeVO );
			ExecuteUtil.execute( arrangeVO );
		}
	}
}