package watercolor.controller
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.CommandVO;
	import watercolor.commands.vo.CreateVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.Element;
	import watercolor.events.ElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.CoordinateUtils;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.MatrixInfo;


	/**
	 * Add Elements to Targeted Layer
	 *
	 * @author Sean Thayne.
	 */
	public class AddElementCommand extends Command
	{


		[Inject]
		/**
		 * Event describing the Children Element(s), and the Parent Layer
		 */
		public var event:ElementEvent;


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

			for each( var element:Element in event.elements )
			{
				commandVO.addCommand( new CreateVO( element, new Position( event.parent, event.parent.numElements )));
				
				if (model.workArea.isolationLayer && event.parent == model.workArea.isolationLayer.contentGroup)
				{
					var m:Matrix = model.workArea.isolationLayer.contentGroup.transform.matrix.clone();
					m.invert();
					
					element.transform.matrix = m;
					
					if (event.position)
					{
						var p:Point = CoordinateUtils.localToLocal(model.workArea.isolationLayer.contentGroup, model.workArea.isolationLayer, new Point(event.position.x, event.position.y));						
						p = CoordinateUtils.localToLocal(model.workArea.isolationLayer, model.workArea.isolationLayer.contentGroup, new Point(( p.x - ( element.widthAfterTransform ) / 2 ), ( p.y - ( element.heightAfterTransform ) / 2 )));
						
						element.x = p.x;
						element.y = p.y;
					}					
				} 
				else
				{
					if (event.position)
					{	
						// set the center of the glyph to be right where the user let go of the mouse
						element.x = ( event.position.x - ( element.widthAfterTransform ) / 2 );
						element.y = ( event.position.y - ( element.heightAfterTransform ) / 2 );
						
					}
				}
			}
			//Add to history, and execute.
			model.history.addCommand( commandVO );
			ExecuteUtil.execute( commandVO );
			
			// Now go through and ajust those that were added to the isolation layer
			// this is so that the history manager will think that the element was added
			// in the right place
			for each (var create:CreateVO in commandVO.commands)
			{
				if (model.workArea.isolationLayer && create.position.parent == model.workArea.isolationLayer.contentGroup)
				{
					create.position.parent = model.workArea.isolationLayer.lastIsolatedElement;
				}
			}
		}
	}
}
