package watercolor.controller.mediators
{
	import flash.events.MouseEvent;
	
	import spark.events.TextOperationEvent;
	
	import watercolor.elements.Text;
	import watercolor.events.TextAreaEvent;
	
	public class TextAreaMediator extends ElementMediator
	{
		override public function onRegister():void
		{
			super.onRegister();
			
			if (element is Text) {
				eventMap.mapListener(Text(element).textInput, TextOperationEvent.CHANGE, onTextChange);
				eventMap.mapListener(Text(element).textInput, MouseEvent.CLICK, onMouseClick);
			}
		}
		
		override public function onRemove():void
		{
			if (element is Text) {
				eventMap.unmapListener(Text(element).textInput, TextOperationEvent.CHANGE, onTextChange);
				eventMap.unmapListener(Text(element).textInput, MouseEvent.CLICK, onMouseClick);
			}
		}
		
		protected function onTextChange(event:TextOperationEvent):void {
			element.callLater(updateSelection);
		}
		
		protected function updateSelection():void {
			model.selectionManager.updateSelection(false, true, true);
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			dispatch(new TextAreaEvent(TextAreaEvent.EVENT_TEXT_AREA_CLICK, Text(element)));
		}
		
		/**
		 * Function to call when an element has been clicked on
		 * @param event The mouse click event
		 */
		protected override function handleElementMouseDown( event:MouseEvent ):void
		{
			// If spacebar is currently pressed, do not select element.  Spacebar means we are panning.
			var workAreaMediator:WorkareaMediator = WorkareaMediator(mediatorMap.retrieveMediator(model.workArea));
			if (workAreaMediator.keyDown[ 32 ])
			{
				return;
			}
			
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
				model.workArea.selectionLayer.transformLayer.begin( false );
			}
		}
	}
}