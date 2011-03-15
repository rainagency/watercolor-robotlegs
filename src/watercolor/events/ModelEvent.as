package watercolor.events
{
	import flash.events.Event;


	/**
	 * Events that are thrown from the watercolor model
	 * @author mediarain
	 */
	public class ModelEvent extends Event
	{

		/**
		 * Indicates that the workarea has been set or changed in the model
		 * @default
		 */
		public static const WORKAREA_UPDATED:String = "eventWorkAreaUpdated";

		public static const RULERUNIT_UPDATED:String = "eventRulerUnitUpdated";

		public static const HISTORY_MANAGER_CHANGING:String = 'evenHistoryManagerChanging';

		public static const HISTORY_MANAGER_CHANGED:String = "eventHistoryManagerChanged";

		public static const SELECTION_MANAGER_CHANGED:String = 'selectionManagerChanged';
		
		public static const SELECTION_MANAGER_CHANGING:String = 'selectionManagerChanging';
		
		/**
		 *
		 * @param type
		 */
		public function ModelEvent( type:String )
		{
			super( type, true, true );
		}


		/**
		 * Overriden <code>clone()</code> method used to clone event; commonly used in bubbling.
		 */
		override public function clone():Event
		{
			return new ModelEvent( this.type );
		}
	}
}