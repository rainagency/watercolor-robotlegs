package watercolor.controller
{
	import org.robotlegs.mvcs.Command;

	import watercolor.commands.vo.CreateVO;
	import watercolor.commands.vo.Position;
	import watercolor.events.LayerEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * Add Layer to Workarea
	 *
	 * @author Sean Thayne.
	 */
	public class AddLayerCommand extends Command
	{


		[Inject]
		/**
		 * Event describing the Layer and Workeara.
		 */
		public var event:LayerEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;


		/**
		 * Add Layer to Workarea.
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var createVO:CreateVO = new CreateVO( event.layer, new Position( event.workArea, model.workArea.layers.length ));

			//Add to history, and execute.
			model.history.addCommand( createVO );
			ExecuteUtil.execute( createVO );
		}
	}
}