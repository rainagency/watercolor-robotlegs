package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.DeleteVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.components.Workarea;
	import watercolor.events.LayerEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * Removes Layer
	 *
	 * @author Sean Thayne.
	 */
	public class RemoveLayerCommand extends Command
	{


		[Inject]
		/**
		 * Event describing the Layer to Remove
		 */
		public var event:LayerEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;


		/**
		 * Removes layer.
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var deleteVO:DeleteVO = new DeleteVO(event.layer, event.layer.getPosition());

			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				if (!(model.workArea.isolationLayer.firstIsolatedElement.parent == event.layer))
				{
					isolationMode = true;
					model.workArea.isolationLayer.exit(false, false);
				}
				else
				{
					model.workArea.isolationLayer.exitToLevel(0);
				}
			}
			
			//Add to history, and execute.
			model.history.addCommand(deleteVO);
			ExecuteUtil.execute(deleteVO);
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}
			
			//Update Selection box
			model.selectionManager.updateSelection( true );
		}
	}
}