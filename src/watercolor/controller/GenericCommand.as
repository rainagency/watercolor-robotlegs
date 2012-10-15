package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.events.GenericExecuteEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;
	
	/**
	 * Executes any command VO.
	 */
	public class GenericCommand extends Command
	{
		[Inject]
		public var event:GenericExecuteEvent;
		
		[Inject]
		public var model:WaterColorModel;
		
		/**
		 * Execute function for executing a command VO.
		 */
		override public function execute():void
		{
			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				model.workArea.isolationLayer.exit(false, false);		
			}
			
			model.history.addCommand( event.commandVO );
			ExecuteUtil.execute( event.commandVO );
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}
			
			//Update Selection box
			model.selectionManager.updateSelection(false, true, true);
		}
	}
}