package watercolor.controller
{
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.ArrangeVO;
	import watercolor.elements.Element;
	import watercolor.events.ElementEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.type.ArrangeDirectionType;
	import watercolor.utils.ExecuteUtil;


	/**
	 * Changes a Element(s)' index with.
	 * 
	 * This will move the Element upwards/downwards in the viewstack.
	 *
	 * @see watercolor.commands.vo.ArrangeVO
	 * @see watercolor.execute.ArrangeExecute
	 * @see watercolor.controller.ArrangeCommand
	 * @see watercolor.type.ArrangeDirectionType
	 *
	 * @author Sean Thayne
	 */
	public class ChangeElementPositionCommand extends Command
	{


		[Inject]
		/**
		 * Arrange Event
		 */
		public var event:ElementEvent;


		[Inject]
		/**
		 * Water Color Model
		 */
		public var model:WaterColorModel;


		/**
		 * Attach a element to position.
		 *
		 */
		override public function execute():void
		{
			var el:Element;
			var arrangeVO:ArrangeVO;
			
			var isolationMode:Boolean = false;
			if (model.workArea.isolationLayer && model.workArea.isolationMode)
			{
				isolationMode = true;
				model.workArea.isolationLayer.exit(false, false);
			}
			
			//Loop through all elements and give them new positions.
			for each( el in event.elements )
			{
				//Generate WaterColor CommandVO.
				arrangeVO = new ArrangeVO();
				arrangeVO.originalPosition = el.getPosition();
				arrangeVO.newPosition = arrangeVO.originalPosition.clone();
				arrangeVO.element = el;
				
				switch (event.direction)
				{
					case ArrangeDirectionType.TOP:
						if (el.parent.getChildIndex(el) != el.parent.numChildren -1)
							arrangeVO.newPosition.index = arrangeVO.newPosition.parent.numElements - 1;
						else
							continue
						break;
					case ArrangeDirectionType.BOTTOM:
						if (el.parent.getChildIndex(el) > 0)
							arrangeVO.newPosition.index = 0;
						else
							continue;
						break;
					case ArrangeDirectionType.UP:
						if (el.parent.getChildIndex(el) != el.parent.numChildren - 1)
							arrangeVO.newPosition.index++;
						else
							continue;
						break;
					case ArrangeDirectionType.DOWN:
						if (el.parent.getChildIndex(el) > 0)
							arrangeVO.newPosition.index--;
						else
							continue;
						break;
					default:
						trace("ElementEvent Direction Not Recognized");
						continue;
				}
				
				//Add to history, and execute.
				model.history.addCommand( arrangeVO );
				ExecuteUtil.execute( arrangeVO );
			}
			
			if (isolationMode)
			{
				model.workArea.isolationLayer.enter();
			}
		}
	}
}