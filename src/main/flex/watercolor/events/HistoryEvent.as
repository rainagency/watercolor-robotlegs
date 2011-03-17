package watercolor.events
{
	import flash.events.Event;


	public class HistoryEvent extends Event
	{
		public static const UNDO:String = "HistoryEventUndo";


		public static const REDO:String = "HistoryEventRedo";


		public function HistoryEvent( type:String )
		{
			super( type, false, false );
		}


		override public function clone():Event
		{
			return new HistoryEvent( type )
		}
	}
}