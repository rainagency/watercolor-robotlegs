package watercolor.controller.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	
	import org.robotlegs.base.EventMap;
	
	import watercolor.elements.Element;
	import watercolor.elements.Path;
	import watercolor.elements.TextGroup;
	import watercolor.events.ElementSelectionEvent;
	import watercolor.events.SelectedTextGroupEvent;
	import watercolor.events.SelectionManagerEvent;
	import watercolor.events.TextGroupEvent;
	
	/**
	 * Mediator for a Text Group
	 * @author mediarain
	 */
	public class TextGroupMediator extends ElementMediator
	{
		/**
		 * 
		 */
		public function TextGroupMediator()
		{
			super();
		}
		
		/**
		 * Register event listeners
		 */ 
		override public function onRegister():void
		{
			super.onRegister();
			
			eventMap.mapListener(element, TextGroupEvent.RENDER, handleItemRender);
			eventMap.mapListener(element, TextGroupEvent.REPLACE, handleReplace);
			
			eventMap.mapListener( element, ElementSelectionEvent.ELEMENT_SELECTED, elementsAdded );
			eventMap.mapListener( element, ElementSelectionEvent.ELEMENT_DESELECTED, elementsRemoved );
		}
		
		/**
		 * Handler for when some text has been replaced in the text group.
		 * The purpose of this function is to turn on the selection box once
		 * something has been entered in a text group.  So if there is no text, 
		 * then the selection box should not show up.
		 * @param event
		 */
		protected function handleReplace(event:TextGroupEvent):void {
			
			// check if the text group has some text and if it isn't already selected
			// if (model.selection.elements.indexOf(element) == -1 && TextGroup(element).lettersByIndex.length > 0) {
			if (model.selectionManager.elements.indexOf(element) == -1 && TextGroup(element).text.length > 0) {
				
				// add it to the list of selected items
				model.selectionManager.addElement(element);
			}
			
		}
		
		/**
		 * Handler for when the display in the text group has changed
		 * Thie purpose of this function is to update the selection box as
		 * things change in the text group
		 * @param event
		 */
		protected function handleItemRender(event:TextGroupEvent):void {							
			updateSelectionBox();
		}
		
		/**
		 * Function for updating the selection box surrounding the text group
		 */
		protected function updateSelectionBox():void {
			
			element.validateNow();
			
			// if there is text inside of the text group then update the selection box
			// if (TextGroup(element).lettersByIndex.length > 0) {
			if (TextGroup(element).text.length > 0) {
				model.selectionManager.updateSelection(false, true, true);

			// else turn off the selection box
			} else {
				
				if (model.selectionManager.elements.indexOf(element) != -1)
				{
					model.selectionManager.removeElement(element);
				}
				else
				{
					model.selectionManager.clear();
				}
			}
		}
		
		/**
		 * Handler for when anything is changed in the selection manager
		 */
		protected function elementsAdded( event:ElementSelectionEvent ):void
		{
			eventDispatcher.dispatchEvent(new SelectedTextGroupEvent(SelectedTextGroupEvent.TEXT_GROUP_SELECTED, element as TextGroup));
		}
		
		/**
		 * Handler for when anything is changed in the selection manager
		 */
		protected function elementsRemoved( event:ElementSelectionEvent ):void
		{
			eventDispatcher.dispatchEvent(new SelectedTextGroupEvent(SelectedTextGroupEvent.TEXT_GROUP_UNSELECTED, element as TextGroup));
		}
		
		/**
		 * Handle TextGroupChange Event
		 */ 
		protected function handleChange(event:TextGroupEvent):void
		{
			// check if the text group has some text and if it isn't already selected
			if (model.selectionManager.elements.indexOf(element) == -1 && TextGroup(element).lettersByIndex.length > 0) {
				
				// add it to the list of selected items
				model.selectionManager.addElement(element);
			}
		}
	}
}