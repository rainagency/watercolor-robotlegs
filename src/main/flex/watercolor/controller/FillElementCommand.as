package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.PropertyVO;
	import watercolor.elements.Element;
	import watercolor.elements.interfaces.IElementGraphic;
	import watercolor.events.FillElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * 
	 * @author mediarain
	 */
	public class FillElementCommand extends Command
	{

		[Inject]
		/**
		 * Event listing the elements and the fill to use
		 */
		public var event:FillElementEvent;


		[Inject]
		/**
		 * WaterColor Model
		 */
		public var model:WaterColorModel;


		/**
		 * Add Element(s) to Target.
		 */
		override public function execute():void
		{
			//Generate WaterColor CommandVO.
			var commandVO:GroupCommandVO = new GroupCommandVO();
			
			// go through each element and set up a property vo for changing the fill
			for each (var elm:IElementGraphic in event.elements)
			{
				var property:PropertyVO = new PropertyVO();
				property.element = Element(elm);
				property.originalProperties = new Object();
				property.newProperties = new Object();				
				property.newProperties["fill"] = event.fill;
				property.originalProperties["fill"] = elm.fill;
				
				commandVO.addCommand(property);
			}
						
			//Add to history, and execute.
			model.history.addCommand( commandVO );
			ExecuteUtil.execute( commandVO );
			
			dispatch(new FillElementEvent(FillElementEvent.FILLED, event.elements, event.fill));			
		}
	}
}