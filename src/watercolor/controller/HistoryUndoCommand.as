package watercolor.controller
{
	import flash.utils.Dictionary;
	
	import org.robotlegs.mvcs.Command;
	
	import watercolor.elements.Element;
	import watercolor.elements.Layer;
	import watercolor.models.WaterColorModel;


	/**
	 * Command to undo a history command
	 * @author mediarain
	 */
	public class HistoryUndoCommand extends Command
	{


		[Inject]
		/**
		 *
		 * @default
		 */
		public var model:WaterColorModel;


		/**
		 * execute: Undo a command in the history manager
		 */
		override public function execute():void
		{
			var exitedIsolation:Boolean = false;
			
			// check if we are in isolation mode
			if( model.workArea.isolationLayer && model.workArea.isolationLayer.elementLength() > 0 )
			{
				model.workArea.isolationLayer.exit(false, false);
				exitedIsolation = true;
			}
			
			var dictionary:Dictionary = new Dictionary();
			for each (var elm:Element in model.selectionManager.elements)
			{
				dictionary[elm] = elm.parent;
			}

			// undo the last transformation vo
			model.history.undo();
			
			model.selectionManager.clear();			
			for (var key:Object in dictionary)
			{
				if (key.parent == dictionary[key])
				{
					model.selectionManager.addElement(Element(key));
				}
			}			
			dictionary = null;

			// if we exited isolation mode then go back in
			if(exitedIsolation)
			{
				model.workArea.isolationLayer.enter();
				
				if (model.workArea.isolationLayer.elementLength() == 0)
				{
					model.workArea.isolationLayer.exitToLevel(0);
				}
				
				model.selectionManager.updateSelection(true);
			}
		}
	}
}