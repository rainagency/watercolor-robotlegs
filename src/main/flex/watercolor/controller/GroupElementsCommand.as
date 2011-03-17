package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.CommandVO;
	import watercolor.commands.vo.CreateVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.events.GroupingEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.GroupingUtil;


	public class GroupElementsCommand extends Command
	{


		[Inject]
		public var event:GroupingEvent;


		[Inject]
		public var model:WaterColorModel;


		/**
		 * execute: Groups elements together inside of a group element
		 */
		override public function execute():void
		{
			if( event.elements.length > 1 )
			{
				var isolationMode:Boolean = false;
				if (model.workArea.isolationLayer && model.workArea.isolationMode)
				{
					isolationMode = true;
					model.workArea.isolationLayer.exit(false, false);
				}
				
				var vo:CommandVO = GroupingUtil.group( event.parent, event.elements );
				
				model.history.addCommand( vo );
				ExecuteUtil.execute( vo );
				
				if (isolationMode)
				{
					model.workArea.isolationLayer.enter();
				}

				model.selectionManager.clear();
				
				if (vo is GroupCommandVO && GroupCommandVO(vo).commands[0] is CreateVO && GroupCommandVO(vo).commands[0].element.parent)
				{
					model.selectionManager.addElement(GroupCommandVO(vo).commands[0].element);
				}
			}
		}
	}
}