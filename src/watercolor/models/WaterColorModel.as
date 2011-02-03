package watercolor.models
{
	import org.robotlegs.mvcs.Actor;
	
	import watercolor.elements.components.Workarea;
	import watercolor.elements.interfaces.IElementContainer;
	import watercolor.events.ModelEvent;
	import watercolor.managers.HistoryManager;
	import watercolor.managers.SelectionManager;
	import watercolor.type.WorkareaCursorType;


	/**
	 *
	 * @author mediarain
	 */
	public class WaterColorModel extends Actor
	{
		private var _workArea:Workarea;


		/**
		 *
		 * @return
		 */
		public function get workArea():Workarea
		{
			return _workArea;
		}


		/**
		 *
		 * @param value
		 */
		public function set workArea( value:Workarea ):void
		{
			_workArea = value;

			// dispatch this event to indicate that the workarea has been set or changed
			eventDispatcher.dispatchEvent( new ModelEvent( ModelEvent.WORKAREA_UPDATED ));
		}

		private var _workAreaDPI:uint = 72;

		/**
		 * 
		 * @return 
		 */
		public function get workAreaDPI():uint
		{
			return _workAreaDPI;
		}

		/**
		 * 
		 * @param value
		 */
		public function set workAreaDPI(value:uint):void
		{
			_workAreaDPI = value;
		}
		

		/**
		 * 
		 * @default 
		 */
		public var cursorMode:String = WorkareaCursorType.DEFAULT;


		private var _history:HistoryManager;


		/**
		 *
		 * @return
		 */
		public function get history():HistoryManager
		{
			return _history;
		}


		/**
		 *
		 * @param value
		 */
		public function set history( value:HistoryManager ):void
		{
			_history = value;
			eventDispatcher.dispatchEvent( new ModelEvent( ModelEvent.HISTORY_MANAGER_CHANGED ));
		}


		private var _selection:SelectionManager;


		/**
		 *
		 * @return
		 */
		public function get selectionManager():SelectionManager
		{
			return _selection;
		}


		/**
		 *
		 * @param value
		 */
		public function set selectionManager( value:SelectionManager ):void
		{
			_selection = value;
		}


		/**
		 *
		 */
		public function WaterColorModel()
		{
		}


		/**
		 * @return Current Layer or Content Group from Isolation Layer
		 */
		public function get currentOrIsolationLayer():IElementContainer
		{
			var currentContainer:Object;

			var parent:Object;
			if( workArea.isolationLayer && workArea.isolationMode )
			{
				currentContainer = workArea.isolationLayer.contentGroup;
			}
			else
			{
				currentContainer = workArea.currentLayer;
			}
			return currentContainer as IElementContainer;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get currentOrIsolatedParent():IElementContainer
		{
			var currentContainer:Object;
			
			var parent:Object;
			if( workArea.isolationLayer && workArea.isolationMode )
			{
				currentContainer = workArea.isolationLayer.lastIsolatedElement;
			}
			else
			{
				currentContainer = workArea.currentLayer;
			}
			return currentContainer as IElementContainer;
		}
	}
}