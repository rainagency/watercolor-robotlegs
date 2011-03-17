package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.ArrangeVO;
	import watercolor.commands.vo.CommandVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.events.GroupingEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.GroupingUtil;


	public class UnGroupElementsCommand extends Command
	{


		[Inject]
		public var event:GroupingEvent;


		[Inject]
		public var model:WaterColorModel;


		/**
		 * execute: Moves elements outside of a group and then deletes the group
		 */
		override public function execute():void
		{
			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				model.workArea.isolationLayer.exit(false, false);
			}
			
			var vo:CommandVO = GroupingUtil.ungroup( event.parent, event.elements[ 0 ]);
			
			model.history.addCommand( vo );
			ExecuteUtil.execute( vo );
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}

			model.selectionManager.clear();
			
			if (vo is GroupCommandVO)
			{
				for each (var command:CommandVO in GroupCommandVO(vo).commands)
				{
					if (command is ArrangeVO)
					{
						model.selectionManager.addElement(ArrangeVO(command).element);
					}
				}
			}
		}
	}
}