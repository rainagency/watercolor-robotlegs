package watercolor.controller
{
	import flash.text.TextFormat;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBaseline;
	
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import org.robotlegs.mvcs.Command;
	
	import spark.components.TextArea;
	
	import watercolor.commands.vo.TextFormatVO;
	import watercolor.events.TextAreaEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;
	
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
				var oldTxtLayFmt:TextLayoutFormat = ta.getFormatOfRange(null, ta.selectionAnchorPosition, ta.selectionActivePosition);
				
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
						break;
					
					case TextAreaEvent.EVENT_ALIGN_LEFT_TEXT:
						txtLayFmt.textAlign = TextAlign.LEFT;
						break;
					
					case TextAreaEvent.EVENT_ALIGN_MIDDLE_TEXT:
						txtLayFmt.textAlign = TextAlign.CENTER;
						break;
					
					case TextAreaEvent.EVENT_ALIGN_RIGHT_TEXT:
						txtLayFmt.textAlign = TextAlign.RIGHT;
						break;
				}
				
				var textFormatVO:TextFormatVO = new TextFormatVO();
				textFormatVO.element = event.textArea;
				textFormatVO.start = ta.selectionAnchorPosition;
				textFormatVO.end = ta.selectionActivePosition;
				textFormatVO.oldFmt = oldTxtLayFmt;
				textFormatVO.newFmt = txtLayFmt;
				
				//Add to history, and execute.
				wcModel.history.addCommand( textFormatVO );
				ExecuteUtil.execute( textFormatVO );
				
				event.textArea.textInput.setFocus();
				event.textArea.textInput.callLater(updateSelection);
			}
		}
		
		protected function updateSelection():void {
			wcModel.selectionManager.updateSelection(false, true, true);
		}
		
	}
}