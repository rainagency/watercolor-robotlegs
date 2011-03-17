package watercolor.controller
{
	import mx.core.IVisualElementContainer;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.DeleteVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.Element;
	import watercolor.events.ElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * Removes Elements
	 *
	 * @author Sean Thayne.
	 */
	public class RemoveElementCommand extends Command
	{


		[Inject]
		public var event:ElementEvent;


		[Inject]
		public var model:WaterColorModel;


		/**
		 * Removes the elements from the work area
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var command:GroupCommandVO = new GroupCommandVO();

			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				model.workArea.isolationLayer.exit(false, false);
			}
			
			for each( var element:Element in event.elements ) {
				command.commands.push( new DeleteVO( element, element.getPosition()));
			}

			// Do not comment this out
			// we need to reverse the order of commands
			// the reason for this is because we cannot undo a list backwards
			// if we do it backwards, then it will start with an index above 0
			// and you cannot insert items into a collection at index 3 if there is no
			// index 0, 1, or 2.
			command.commands = command.commands.reverse();
							
			//Add to history, and execute.
			ExecuteUtil.execute( command );
			model.history.addCommand( command );

			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}
			
			//Update Selection box
			model.selectionManager.updateSelection();
		}
	}
}