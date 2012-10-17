package watercolor.controller.mediators
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.PropertyVO;
	import watercolor.commands.vo.TextFormatVO;
	import watercolor.elements.Text;
	import watercolor.events.StyleTextAreaEvent;
	import watercolor.events.TextEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.TextLayoutFormatUtil;
	
	public class TextAreaMediator extends ElementMediator
	{
		private var timer:Timer;
		private var oldText:String = "";
		private var oldProps:Vector.<TextFormatVO> = new Vector.<TextFormatVO>();
		
		[Inject]
		public var wcModel:WaterColorModel;
		
		protected function get textInput():TextArea {
			if (element && element is Text) {
				return Text(element).textInput;
			}
			
			return null;
		}
		
		override public function onRegister():void
		{
			super.onRegister();
			
			timer = new Timer(2000, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimerComplete);
			
			if (textInput) {
				eventMap.mapListener(textInput, TextOperationEvent.CHANGE, onTextChange);
				eventMap.mapListener(textInput, MouseEvent.MOUSE_DOWN, onMouseDown);
				
				eventMap.mapListener(textInput, KeyboardEvent.KEY_UP, onKeyUp);
				
				eventMap.mapListener(Text(element), TextEvent.EVENT_TEXT_AREA_CHANGED, onTextChanged);
				eventMap.mapListener(Text(element), TextEvent.EVENT_TEXT_MODIFIED, onTextModified);
			}
		}
		
		override public function onRemove():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimerComplete);
			
			if (textInput) {
				eventMap.unmapListener(textInput, TextOperationEvent.CHANGE, onTextChange);
				eventMap.unmapListener(textInput, MouseEvent.MOUSE_DOWN, onMouseDown);
				
				eventMap.unmapListener(textInput, KeyboardEvent.KEY_UP, onKeyUp);
				
				eventMap.unmapListener(Text(element), TextEvent.EVENT_TEXT_AREA_CHANGED, onTextChanged);
				eventMap.unmapListener(Text(element), TextEvent.EVENT_TEXT_MODIFIED, onTextModified);
			}
		}
		
		protected function onTextChanged(event:TextEvent):void {
			oldProps = TextLayoutFormatUtil.grabTextRanges(Text(element), 0, Text(element).text.length);
		}
		
		protected function onTextModified(event:TextEvent):void {
			oldText = event.currentTarget.text;
		}
		
		protected function onTextChange(event:TextOperationEvent):void {
			
			timer.stop();
			timer.start();
			
			element.callLater(updateSelection);
		}
		
		protected function updateSelection():void {
			model.selectionManager.updateSelection(false, true, true);
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			eventMap.mapListener(element.stage, MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			eventMap.unmapListener(element.stage, MouseEvent.MOUSE_UP, onMouseUp);
			
			if (textInput) {
				checkIfTextIsSaved();
				dispatch(new StyleTextAreaEvent(StyleTextAreaEvent.EVENT_TEXT_AREA_CLICK, Text(element)));
			}
		}
		
		protected function onKeyUp(event:KeyboardEvent):void {
			
			var character:String = String.fromCharCode(event.charCode);
			
			if (textInput && event.ctrlKey && character.toLocaleLowerCase() == 'a') {
				//trace("Start: " + textInput.selectionAnchorPosition + ", End: " + textInput.selectionActivePosition);
				checkIfTextIsSaved();
				dispatch(new StyleTextAreaEvent(StyleTextAreaEvent.EVENT_TEXT_AREA_CLICK, Text(element)));
			}
			
		}
		
		protected function onTimerComplete(event:TimerEvent = null):void {
			
			var group:GroupCommandVO = new GroupCommandVO();
			
			var subGroup1:GroupCommandVO = new GroupCommandVO();
			var subGroup2:GroupCommandVO = new GroupCommandVO();
			
			var prop:PropertyVO = new PropertyVO();
			prop.element = element;
			prop.originalProperties = new Object();
			prop.originalProperties.text = oldText;
			
			var prop2:PropertyVO = new PropertyVO();
			prop2.element = element;
			prop2.newProperties = new Object();
			prop2.newProperties.text = Text(element).text;
			
			var fmt:TextFormatVO;
			
			for each (fmt in oldProps) {
				subGroup1.addCommand(fmt);
			}
			subGroup1.addCommand(prop);
			
			var fmts:Vector.<TextFormatVO> = TextLayoutFormatUtil.grabTextRanges(Text(element), 0, Text(element).text.length);
			subGroup2.addCommand(prop2);
			for each (fmt in fmts) {
				subGroup2.addCommand(fmt);
			}
			
			group.addCommand(subGroup1);
			group.addCommand(subGroup2);
			
			wcModel.history.addCommand(group);
			
			oldText = Text(element).text;
			oldProps = fmts;
		}
		
		protected function checkIfTextIsSaved():void {

			if (timer.running) {
				
				timer.stop();
				onTimerComplete();
			}
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