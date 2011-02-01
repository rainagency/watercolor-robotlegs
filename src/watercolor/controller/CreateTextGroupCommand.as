package watercolor.controller
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.CreateVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.TextGroup;
	import watercolor.events.CreateTextGroupEvent;
	import watercolor.events.SelectedTextGroupEvent;
	import watercolor.events.TextGroupCreatedEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;

	/**
	 * Command for creating a text group
	 * @author mediarain
	 */
	public class CreateTextGroupCommand extends Command
	{

		[Inject]
		/**
		 * CreateTextGroupEvent
		 * @default 
		 */
		public var event:CreateTextGroupEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;

		/**
		 * Command Execute
		 */ 
		override public function execute():void
		{		
			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				model.workArea.isolationLayer.exit(false, false);
			}
			
			// create a new text group with the adapter passed in
			var textGroup:TextGroup = new TextGroup();
			textGroup.mouseChildren = false;
			
			var posX:Number = 50;
			var posY:Number = 100;
			
			if (event.parent is DisplayObject)
			{			
				var p:Point = model.workArea.localToGlobal(new Point(model.workArea.x, model.workArea.y));
				p.x += posX;
				p.y += posY;
				
				p = DisplayObject(event.parent).globalToLocal(p);
				
				textGroup.x = p.x;
				textGroup.y = p.y;
			}
			else
			{
				textGroup.x = posX
				textGroup.y = posY;
			}
			
			if (event.adapter) {
				textGroup.adapter = event.adapter;
			}
			
			// set up a create vo for creating the text group and setting that in the history manager
			var command:CreateVO = new CreateVO();
			command.element = textGroup;
			command.position = new Position(event.parent, event.parent.numElements);
			
			// execute the vo and save it in the history manager
			ExecuteUtil.execute( command );
			model.history.addCommand( command );
			
			// make sure nothing is selected
			model.selectionManager.clear();
			
			// Add default text
			if (event.text)
			{
				textGroup.validateNow(); // this doesn't sound right...
				textGroup.text = event.text;
			}
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}
			
			// dispatch an event to indicate that this text group is selected
			textGroup.dispatchEvent(new TextGroupCreatedEvent(TextGroupCreatedEvent.TEXT_GROUP_CREATED, textGroup));	
		}
	}
}