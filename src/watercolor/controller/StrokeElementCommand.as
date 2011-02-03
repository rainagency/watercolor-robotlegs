package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.PropertyVO;
	import watercolor.elements.Element;
	import watercolor.elements.interfaces.IElementGraphic;
	import watercolor.events.StrokeElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;


	/**
	 * 
	 * @author mediarain
	 */
	public class StrokeElementCommand extends Command
	{

		[Inject]
		/**
		 * Event listing the elements and the fill to use
		 */
		public var event:StrokeElementEvent;


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
				property.newProperties["stroke"] = event.stroke;
				property.originalProperties["stroke"] = elm.stroke;
				
				commandVO.addCommand(property);
			}
						
			//Add to history, and execute.
			model.history.addCommand( commandVO );
			ExecuteUtil.execute( commandVO );
			
			dispatch(new StrokeElementEvent(StrokeElementEvent.STROKED, event.elements, event.stroke));			
		}
	}
}