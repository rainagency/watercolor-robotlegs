package watercolor.controller
{
	import flashx.textLayout.edit.SelectionManager;

	import org.robotlegs.mvcs.Command;

	import watercolor.commands.vo.Position;
	import watercolor.commands.vo.PropertyVO;
	import watercolor.elements.components.Workarea;
	import watercolor.events.LayerEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * Updates a Layer's properties
	 *
	 * -color
	 * -name
	 * -visibility
	 *
	 * @see watercolor.models.vo.LayerPropertiesVO
	 *
	 * @author Sean Thayne.
	 */
	public class ChangeLayerPropertiesCommand extends Command
	{


		[Inject]
		/**
		 * Event containing properties and layer
		 */
		public var event:LayerEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;


		/**
		 * Modifies the layer's properties.
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var propertyVO:PropertyVO = event.newLayerProperties.createPropertyExecuteVO( event.layer );

			if( event.newLayerProperties.addToHistory )
			{
				//Add to history
				model.history.addCommand( propertyVO );
			}

			//execute.
			ExecuteUtil.execute( propertyVO );

			//Update Selection box
			model.selectionManager.updateSelection();
		}
	}
}