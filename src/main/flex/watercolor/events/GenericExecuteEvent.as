package watercolor.events
{
	import flash.events.Event;
	
	import watercolor.commands.vo.CommandVO;
	
	public class GenericExecuteEvent extends Event
	{
		public static const GENERIC_EXECUTE:String = 'waterColorGenericExecute';
		
		/**
		 *
		 * The command VO that is sent in the event.
		 *
		 * This can be any raw WaterColor command you want executed.
		 */
		public var commandVO:CommandVO;
		
		public function GenericExecuteEvent(type:String, commandVO:CommandVO)
		{
			super(type, true, true);
			this.commandVO = commandVO;
		}
		
		override public function clone():Event
		{
			return new GenericExecuteEvent(type, commandVO);
		}
	}
}