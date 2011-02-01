package watercolor.controller
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.robotlegs.mvcs.Command;
	
	import spark.components.Group;
	
	import watercolor.events.CreateTextGroupEvent;
	import watercolor.events.ElementEvent;
	import watercolor.events.GroupingEvent;
	import watercolor.events.HistoryEvent;
	import watercolor.events.IsolationEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.type.ArrangeDirectionType;
	
	/**
	 * Handle Global Keyboard Events
	 * 
	 * NOTE: Zoom In/Out and Panning keyboard shortcuts are all handled within the Workarea Mediator
	 * 
	 * @author Brady White
	 */ 
	public class KeyboardCommand extends Command
	{
		public static const A:uint = 65;
		public static const Z:uint = 90;
		public static const Y:uint = 89;
		public static const OPEN_BRACKET:uint = 219; // [
		public static const CLOSE_BRACKET:uint = 221; // ]
		public static const UP:uint = 38;
		public static const DOWN:uint = 40;
		public static const LEFT:uint = 37;
		public static const RIGHT:uint = 39;
		public static const G:uint = 71;
		public static const U:uint = 85;
		public static const T:uint = 84;
		public static const BACKSPACE:uint = 8;
		public static const DELETE:uint = 46;
		public static const ESCAPE:uint = 27;
		
		public static const NUDGE_SMALL:int = 1;
		public static const NUDGE_LARGE:int = 5;
		
		[Inject]
		/**
		 * KeyDown Event
		 */ 
		public var event:KeyboardEvent;
		
		[Inject]
		/**
		 * Watercolor Model
		 */ 
		public var waterColorModel:WaterColorModel;
		
		override public function execute():void
		{
			if ( event.keyCode == KeyboardCommand.OPEN_BRACKET || (event.ctrlKey && event.keyCode == KeyboardCommand.DOWN ) ) 
			{
				// Send Backward
				dispatch( new ElementEvent( ElementEvent.POSITION_CHANGE, waterColorModel.selectionManager.elements, null, null, ArrangeDirectionType.DOWN ));
			}
			else if ( event.keyCode == KeyboardCommand.CLOSE_BRACKET || (event.ctrlKey && event.keyCode == KeyboardCommand.UP ) ) 
			{
				// Send Forward
				dispatch( new ElementEvent( ElementEvent.POSITION_CHANGE, waterColorModel.selectionManager.elements, null, null, ArrangeDirectionType.UP ));
			}
			else if ( event.ctrlKey && ( event.keyCode == KeyboardCommand.Y || (event.shiftKey && event.keyCode == KeyboardCommand.Z ) ) ) 
			{
				// Redo
				dispatch( new HistoryEvent( HistoryEvent.REDO ));
			}
			else if ( event.ctrlKey && event.keyCode == KeyboardCommand.Z ) 
			{
				// Undo
				dispatch( new HistoryEvent( HistoryEvent.UNDO ));
			}
			else if ( event.ctrlKey && event.keyCode == KeyboardCommand.G )
			{
				// Group
				if( waterColorModel.selectionManager.elements.length > 1 )
				{
					dispatch( new GroupingEvent( GroupingEvent.GROUP, waterColorModel.currentOrIsolatedParent, waterColorModel.selectionManager.elements ));
				}
			}
			else if ( event.ctrlKey && event.keyCode == KeyboardCommand.U )
			{
				// Ungroup
				if( waterColorModel.selectionManager.elements.length == 1 
					&& ( waterColorModel.selectionManager.elements[ 0 ] is Group) 
					&& !waterColorModel.selectionManager.elements[ 0 ].mask )
				{
					dispatch( new GroupingEvent( GroupingEvent.UNGROUP, waterColorModel.currentOrIsolatedParent, waterColorModel.selectionManager.elements ));
				}
			}
			else if ( event.ctrlKey && event.keyCode == KeyboardCommand.T )
			{
				// Quick Type Tool
				dispatch( new CreateTextGroupEvent( CreateTextGroupEvent.CREATE_TEXT_GROUP, waterColorModel.currentOrIsolatedParent));
			}
			else if ( event.keyCode == KeyboardCommand.BACKSPACE || event.keyCode == KeyboardCommand.DELETE ) 
			{
				// Delete
				dispatch( new ElementEvent( ElementEvent.REMOVE, waterColorModel.selectionManager.elements ));
			}
			else if ( event.keyCode == KeyboardCommand.ESCAPE ) // Exit out of Isolation Mode
			{
				if (waterColorModel && waterColorModel.workArea && waterColorModel.workArea.isolationLayer && waterColorModel.workArea.isolationMode)
				{
					waterColorModel.workArea.isolationLayer.dispatchEvent(new IsolationEvent(IsolationEvent.UNISOLATE));
				}
			}
			else if ( event.ctrlKey && event.keyCode == KeyboardCommand.A ) // Select All
			{
				// Select All, in Watercolor
				waterColorModel.selectionManager.selectAll();
			}
			else if ( event.keyCode == KeyboardCommand.UP && event.shiftKey)
			{
				waterColorModel.selectionManager.nudgeElements( 0, -KeyboardCommand.NUDGE_LARGE );
			}
			else if ( event.keyCode == KeyboardCommand.DOWN && event.shiftKey)
			{
				waterColorModel.selectionManager.nudgeElements(  0, KeyboardCommand.NUDGE_LARGE );
			}
			else if ( event.keyCode == KeyboardCommand.LEFT && event.shiftKey)
			{
				waterColorModel.selectionManager.nudgeElements( -KeyboardCommand.NUDGE_LARGE, 0 );
			}
			else if ( event.keyCode == KeyboardCommand.RIGHT && event.shiftKey)
			{
				waterColorModel.selectionManager.nudgeElements( KeyboardCommand.NUDGE_LARGE, 0 );
			}
			else if ( event.keyCode == KeyboardCommand.UP)
			{
				waterColorModel.selectionManager.nudgeElements( 0, -KeyboardCommand.NUDGE_SMALL );
			}
			else if ( event.keyCode == KeyboardCommand.DOWN)
			{
				waterColorModel.selectionManager.nudgeElements( 0, KeyboardCommand.NUDGE_SMALL );
			}
			else if ( event.keyCode == KeyboardCommand.LEFT)
			{
				waterColorModel.selectionManager.nudgeElements( -KeyboardCommand.NUDGE_SMALL, 0 );
			}
			else if ( event.keyCode == KeyboardCommand.RIGHT)
			{
				waterColorModel.selectionManager.nudgeElements( KeyboardCommand.NUDGE_SMALL, 0 );
			}
		}
	}
}