package watercolor.controller
{
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import org.robotlegs.mvcs.Command;
	
	import spark.components.TextArea;
	
	import watercolor.events.TextAreaEvent;
	import watercolor.models.WaterColorModel;
	
	/**
	 * 
	 * @author Jeremiah
	 */
	public class ModifyTextAreaCommand extends Command
	{
		[Inject]
		/**
		 * 
		 * @default 
		 */
		public var event:TextAreaEvent;
		
		
		[Inject]
		public var wcModel:WaterColorModel;
		
		/**
		 * Command for loading and parsing design assets
		 */ 
		override public function execute():void {
			
			if (event.textArea) {
			
				var ta:TextArea = event.textArea.textInput;
				
				var txtLayFmt:TextLayoutFormat = ta.getFormatOfRange(null, ta.selectionAnchorPosition, ta.selectionActivePosition);
				
				switch(event.type) {
				
					case TextAreaEvent.EVENT_BOLD_TEXT:
						txtLayFmt.fontWeight = (txtLayFmt.fontWeight == FontWeight.BOLD) ? FontWeight.NORMAL : FontWeight.BOLD;
						break;
					
					case TextAreaEvent.EVENT_ITALIC_TEXT:
						txtLayFmt.fontStyle = (txtLayFmt.fontStyle == FontPosture.ITALIC) ? FontPosture.NORMAL : FontPosture.ITALIC;
						break;
					
					case TextAreaEvent.EVENT_SIZE_TEXT:
						if (event.args.length > 0) {
							txtLayFmt.fontSize = event.args[0];
						}
						break;
					
					case TextAreaEvent.EVENT_COLOR_TEXT:
						if (event.args.length > 0) {
							txtLayFmt.color = event.args[0];
						}
				}
				
				ta.setFormatOfRange(txtLayFmt, ta.selectionAnchorPosition, ta.selectionActivePosition);
				
				event.textArea.textInput.setFocus();
				event.textArea.textInput.callLater(updateSelection);
			}
		}
		
		protected function updateSelection():void {
			wcModel.selectionManager.updateSelection(false, true, true);
		}
		
	}
}