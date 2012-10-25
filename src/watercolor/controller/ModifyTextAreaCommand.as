package watercolor.controller
{
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextDecoration;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.TextFormatVO;
	import watercolor.events.StyleTextAreaEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.TextLayoutFormatUtil;
	
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
		public var event:StyleTextAreaEvent;
		
		
		[Inject]
		public var wcModel:WaterColorModel;
		
		/**
		 * Command for loading and parsing design assets
		 */ 
		override public function execute():void {
			
			if (event.textArea) {
			
				var txtLayFmtArray:Vector.<TextFormatVO> = TextLayoutFormatUtil.grabTextRanges(event.textArea, event.textArea.textInput.selectionAnchorPosition, event.textArea.textInput.selectionActivePosition);
				
				for each (var txtLayFmt:TextFormatVO in txtLayFmtArray) { 
				
					switch(event.type) {
					
						case StyleTextAreaEvent.EVENT_BOLD_TEXT:
							txtLayFmt.newFmt.fontWeight = FontWeight.BOLD;
							break;
						
						case StyleTextAreaEvent.EVENT_ITALIC_TEXT:
							txtLayFmt.newFmt.fontStyle = FontPosture.ITALIC;
							break;
						
						case StyleTextAreaEvent.EVENT_UNDERLINE_TEXT:
							txtLayFmt.newFmt.textDecoration = TextDecoration.UNDERLINE;
							break;
						
						case StyleTextAreaEvent.EVENT_UN_UNDERLINE_TEXT:
							txtLayFmt.newFmt.textDecoration = TextDecoration.NONE;
							break;
						
						case StyleTextAreaEvent.EVENT_UN_BOLD_TEXT:
							txtLayFmt.newFmt.fontWeight = FontWeight.NORMAL;
							break;
						
						case StyleTextAreaEvent.EVENT_UN_ITALIC_TEXT:
							txtLayFmt.newFmt.fontStyle = FontPosture.NORMAL;
							break;
						
						case StyleTextAreaEvent.EVENT_SIZE_TEXT:
							if (event.args.length > 0) {
								txtLayFmt.newFmt.fontSize = event.args[0];
							}
							break;
						
						case StyleTextAreaEvent.EVENT_COLOR_TEXT:
							if (event.args.length > 0) {
								txtLayFmt.newFmt.color = event.args[0];
							}
							break;
						
						case StyleTextAreaEvent.EVENT_ALIGN_LEFT_TEXT:
							txtLayFmt.newFmt.textAlign = TextAlign.LEFT;
							break;
						
						case StyleTextAreaEvent.EVENT_ALIGN_MIDDLE_TEXT:
							txtLayFmt.newFmt.textAlign = TextAlign.CENTER;
							break;
						
						case StyleTextAreaEvent.EVENT_ALIGN_RIGHT_TEXT:
							txtLayFmt.newFmt.textAlign = TextAlign.RIGHT;
							break;
						
					}
				}
				
				var group:GroupCommandVO = new GroupCommandVO()
				
				for each (var textFormatVO:TextFormatVO in txtLayFmtArray) {
					group.commands.push(textFormatVO);
				}
				
				if (!(group.commands.length == 1) || !(group.commands[0] is TextFormatVO) || !(TextFormatVO(group.commands[0]).start == TextFormatVO(group.commands[0]).end)) {
					
					//Add to history
					wcModel.history.addCommand( group );
					
				} 
				
				//Now execute.
				ExecuteUtil.execute( group );
				
				event.textArea.textInput.setFocus();
				event.textArea.textInput.callLater(updateSelection);
				
			}
		}
		
		protected function updateSelection():void {
			wcModel.selectionManager.updateSelection(false, true, true);
		}
	}
}