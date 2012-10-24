package watercolor.controller
{
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.elements.Text;
	import watercolor.events.StyleTextAreaEvent;
	import watercolor.models.WaterColorModel;
	
	/**
	 * 
	 * @author Jeremiah
	 */
	public class InsertLinkTextAreaCommand extends Command
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
			
				var text:Text = event.textArea;
				var textFlow:TextFlow = text.textInput.textFlow;
				
				var slStart:int;
				var elStart:int;
				
				var newSpanStart:SpanElement;
				var newSpanEnd:SpanElement;
				
				var link:LinkElement;
				var linkIndex:int;
				
				var elm:FlowElement;
				
				if (textFlow.flowComposer.numLines > 0) {
					
					var startLeaf:FlowLeafElement = textFlow.findLeaf(text.textInput.selectionAnchorPosition);
					var endLeaf:FlowLeafElement = textFlow.findLeaf(text.textInput.selectionActivePosition);
					
					if (event.type == StyleTextAreaEvent.EVENT_TEXT_AREA_ADD_LINK && event.args.length > 0) {
					
						if (startLeaf is SpanElement && endLeaf is SpanElement && !(startLeaf.parent is LinkElement) && !(endLeaf.parent is LinkElement)) {
							
							var startIndex:int = startLeaf.parent.getChildIndex(startLeaf);
							var endIndex:int = endLeaf.parent.getChildIndex(endLeaf);
							
							var spanList:Array = new Array();
							var linkList:Array = new Array();
							
							for (var x:int = startIndex + 1; x < endIndex; x++) {
								
								elm = startLeaf.parent.getChildAt(x);
								
								// if link element
								if (elm is LinkElement) {
									
									linkList.push(elm);
									
									for (var l:int = 0; l < LinkElement(elm).numChildren; l++) {
										spanList.push(LinkElement(elm).getChildAt(l));
									}
									
								} else {
									
									spanList.push(startLeaf.parent.getChildAt(x));
								}
							}
							
							if (startLeaf != endLeaf) {
								
								slStart = text.textInput.selectionAnchorPosition - startLeaf.getElementRelativeStart(textFlow);
								elStart = text.textInput.selectionActivePosition - endLeaf.getElementRelativeStart(textFlow);
								
								newSpanStart = startLeaf.splitAtPosition(slStart) as SpanElement;
								newSpanEnd = endLeaf.splitAtPosition(elStart) as SpanElement;
								
								link = new LinkElement();
								link.href = event.args[0];
								
								linkIndex = startLeaf.parent.getChildIndex(newSpanStart);
								link.addChild(newSpanStart);
								
								for each (elm in spanList) {
									link.addChild(elm);
								}
								
								link.addChild(endLeaf);
								
								startLeaf.parent.addChildAt(linkIndex, link);
								
								for each (elm in linkList) {
									elm.parent.removeChild(elm);
								}
								
							} else if (text.textInput.selectionAnchorPosition != text.textInput.selectionActivePosition) {
								
								slStart = text.textInput.selectionAnchorPosition - startLeaf.getElementRelativeStart(textFlow);
								newSpanStart = startLeaf.splitAtPosition(slStart) as SpanElement;
								
								elStart = text.textInput.selectionActivePosition - newSpanStart.getElementRelativeStart(textFlow);
								newSpanEnd = newSpanStart.splitAtPosition(elStart) as SpanElement;
								
								link = new LinkElement();
								link.href = event.args[0];
								
								linkIndex = startLeaf.parent.getChildIndex(newSpanStart);
								link.addChild(newSpanStart);
								
								startLeaf.parent.addChildAt(linkIndex, link);
								
							}
							
						} else if (startLeaf is SpanElement && endLeaf is SpanElement && startLeaf.parent is LinkElement) {
							
							LinkElement(startLeaf.parent).href = event.args[0];
						}
						
					} else if (startLeaf is SpanElement && endLeaf is SpanElement && startLeaf.parent is LinkElement && endLeaf.parent is LinkElement && startLeaf.parent == endLeaf.parent) {
						
						var parent:FlowGroupElement = startLeaf.parent.parent;
						var index:int = parent.getChildIndex(startLeaf.parent);
						var length:int = startLeaf.parent.numChildren;
						
						var list:Array = new Array();
						for (var y:int = 0; y < length; y++) {
							list.push(startLeaf.parent.getChildAt(y));
						}
						
						list = list.reverse();
						for each (elm in list) {
							parent.addChildAt(index, elm);
						}
					}
				}
				
				event.textArea.textInput.setFocus();
				event.textArea.textInput.callLater(updateSelection);
			}
		}	
		
		protected function updateSelection():void {
			wcModel.selectionManager.updateSelection(false, true, true);
		}
	}
}