package watercolor.controller.mediators
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.robotlegs.mvcs.Mediator;
	
	import watercolor.elements.Element;
	import watercolor.elements.Group;
	import watercolor.elements.Layer;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.VisualElementUtil;


	/**
	 *
	 * @author mediarain
	 */
	public class ElementMediator extends Mediator
	{


		[Inject]
		public var element:Element;


		[Inject]
		public var model:WaterColorModel;


		/**
		 * Constructor
		 */
		public function ElementMediator()
		{
			super();
		}


		/**
		 * Register event listeners
		 */
		override public function onRegister():void
		{
			if( element.mouseEnabled )
			{
				eventMap.mapListener( element, MouseEvent.MOUSE_DOWN, handleItemSelected );
			}
		}


		/**
		 * Function to call when an element has been clicked on
		 * @param event The mouse click event
		 */
		protected function handleItemSelected( event:MouseEvent ):void
		{
			element.setFocus();
			
			// Set CurrentLayer to this element's layer
			if (parentLayer)
				model.workArea.currentLayer = parentLayer;
			
			if( event.ctrlKey || event.shiftKey )
			{
				if( model.selectionManager.isSelected( element ))
				{
					// if the selected element is already in the list of selected elements and the ctrl key is pressed
					model.selectionManager.removeElement( element );

					//Stop future commands. Avoid activating the transformLayer
					return;
				}
				else if( doubleCheckItemClick( event.stageX, event.stageY ))
				{
					// if the selected elements does not already contain the element that was just clicked on
					model.selectionManager.addElement( element );
				}
			}
			else
			{
				if( !model.selectionManager.isSelected( element ))
				{
					// if the ctrl key is not pressed then empty the current list of selected elements
					model.selectionManager.clear();

					if( doubleCheckItemClick( event.stageX, event.stageY ))
					{
						model.selectionManager.addElement( element );
					}
				}

				if( event.altKey )
				{
					//If shift key is pressed, and more than one item selected then rebuild the selction box.
					model.selectionManager.updateSelection( true, true );
				}
			}

			//Listen for drag movements.
			if( model.selectionManager.elements.length > 0 )
			{
				model.workArea.selectionLayer.transformLayer.begin( true );
			}
		}
		
		protected function doubleCheckItemClick(stageX:Number, stageY:Number):Boolean
		{	
			return VisualElementUtil.getElementRectangle(element, element.parent, true).containsPoint(element.parent.globalToLocal(new Point(stageX, stageY)));
		}
		
		
		/**
		 * Get the Element's Parent Layer
		 * @return element's parent if it is a layer
		 */ 
		public function get parentLayer():Layer
		{
			if (element.parent is Layer)
			{
				return Layer(element.parent);
			}
			else
			{
				return null;
			}
		}
	}
}
