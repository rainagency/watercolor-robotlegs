package watercolor.controller
{
	import watercolor.execute.GroupExecute;
	import watercolor.execute.TransformExecute;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.CommandVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.TransformVO;
	import watercolor.events.ElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.CoordinateUtils;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.MatrixUtil;
	import watercolor.utils.TransformUtil;


	/**
	 *
	 * @author mediarain
	 */
	public class TransformElementsCommand extends Command
	{


		[Inject]
		/**
		 *
		 * @default
		 */
		public var event:ElementEvent;


		[Inject]
		/**
		 *
		 * @default
		 */
		public var model:WaterColorModel;


		/**
		 * Constructor
		 */
		public function TransformElementsCommand()
		{
		}


		/**
		 * Execute function for executing a command VO
		 * This also dispatches a transform complete event
		 */
		override public function execute():void
		{
			model.history.addCommand( event.commandVO );
					
			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				alterTransformVOs(event.commandVO);	
				model.workArea.isolationLayer.exit(false, false);		
			}
			
			ExecuteUtil.execute(event.commandVO);	
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}

			dispatch( new ElementEvent( ElementEvent.TRANSFORM_COMPLETE, null, null, event.commandVO ));

			//Update Selection box
			model.selectionManager.updateSelection();
		}
		
		private function alterTransformVOs(command:CommandVO):void
		{
			if (command is TransformVO)
			{
				if (model.workArea.isolationMode)
				{
					TransformUtil.adjustForIsolationMode(TransformVO(command), model.workArea.isolationLayer);
				}
			}
			else if (command is GroupCommandVO)
			{
				for each (var com:CommandVO in GroupCommandVO(command).commands)
				{
					alterTransformVOs(com);
				}
			}
		}
	}
}