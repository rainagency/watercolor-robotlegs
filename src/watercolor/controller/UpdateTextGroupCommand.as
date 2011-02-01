package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.PropertyVO;
	import watercolor.elements.TextGroup;
	import watercolor.events.UpdateTextGroupEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;

	/**
	 * Update Text Group Command
	 * @author mediarain
	 */
	public class UpdateTextGroupCommand extends Command
	{

		[Inject]
		/**
		 * 
		 * @default 
		 */
		public var event:UpdateTextGroupEvent;


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
			var groupCommand:GroupCommandVO = new GroupCommandVO();
			var property:PropertyVO;
			
			// make sure the text group isn't null
			if (event.textGroups.length > 0) {
							
				for each (var group:TextGroup in event.textGroups) {
				
					// set up a new property vo
					property = new PropertyVO();
					property.element = group;			
					property.originalProperties = new Object();
					property.newProperties = new Object();
										
					// check which type of event called this command
					switch (event.type) {
						
						// adjusting the scale
						case UpdateTextGroupEvent.UPDATE_SCALE:
							property.originalProperties["lettersScale"] = group.lettersScale;
							property.newProperties["lettersScale"] = Number(event.value);
							groupCommand.addCommand(property);
							break;
						
						// adjusting the space between letters
						case UpdateTextGroupEvent.UPDATE_SPACE:
							property.originalProperties["letterSpacing"] = group.letterSpacing;
							property.newProperties["letterSpacing"] = Number(event.value);
							groupCommand.addCommand(property);
							break;
						
						// adjusting the letter spacing method
						case UpdateTextGroupEvent.UPDATE_SPACING_METHOD:
							property.originalProperties["letterSpacingMethod"] = group.letterSpacingMethod;
							property.newProperties["letterSpacingMethod"] = event.value;
							groupCommand.addCommand(property);
							break;
						
						// adjust the direction of the text (vertical or horizontal)
						case UpdateTextGroupEvent.UPDATE_DIRECTION:
							property.originalProperties["textDirection"] = group.textDirection;
							property.newProperties["textDirection"] = event.value;
							groupCommand.addCommand(property);
							break;
						
						// adjust the horizontal alignment when the text is vertical
						case UpdateTextGroupEvent.UPDATE_HORIZONTAL_ALIGN:
							property.originalProperties["horizontalAlign"] = group.verticalAlign;
							property.newProperties["horizontalAlign"] = event.value;
							groupCommand.addCommand(property);
							break;
						
						// adjust the vertical alignment when the text is horizontal
						case UpdateTextGroupEvent.UPDATE_VERTICAL_ALIGN:
							property.originalProperties["verticalAlign"] = group.verticalAlign;
							property.newProperties["verticalAlign"] = event.value;
							groupCommand.addCommand(property);
							break;
						
						// adjust the adapter for the text group
						case UpdateTextGroupEvent.UPDATE_ADAPTER:
							property.originalProperties["adapter"] = group.adapter;
							property.newProperties["adapter"] = event.adapter;
							groupCommand.addCommand(property);
							break;
						default:
							break;
						
					}				
				}				
			} 
			
			// if something changed then execute the property vo and save it in the history manager
			if (groupCommand.commands.length > 0) {
				ExecuteUtil.execute(groupCommand);
				model.history.addCommand(groupCommand);
			}
		}
	}
}