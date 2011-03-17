package watercolor
{
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;
	
	import org.robotlegs.mvcs.Context;
	
	import watercolor.controller.AddElementCommand;
	import watercolor.controller.AddLayerCommand;
	import watercolor.controller.ChangeElementPositionCommand;
	import watercolor.controller.ChangeLayerPositionCommand;
	import watercolor.controller.ChangeLayerPropertiesCommand;
	import watercolor.controller.FillElementCommand;
	import watercolor.controller.GroupElementsCommand;
	import watercolor.controller.HistoryRedoCommand;
	import watercolor.controller.HistoryUndoCommand;
	import watercolor.controller.KeyboardCommand;
	import watercolor.controller.RemoveElementCommand;
	import watercolor.controller.RemoveLayerCommand;
	import watercolor.controller.StrokeElementCommand;
	import watercolor.controller.TransformElementsCommand;
	import watercolor.controller.UnGroupElementsCommand;
	import watercolor.controller.mediators.*;
	import watercolor.elements.Element;
	import watercolor.elements.Ellipse;
	import watercolor.elements.Group;
	import watercolor.elements.Layer;
	import watercolor.elements.Path;
	import watercolor.elements.Rect;
	import watercolor.elements.components.Workarea;
	import watercolor.events.ElementEvent;
	import watercolor.events.FillElementEvent;
	import watercolor.events.GroupingEvent;
	import watercolor.events.HistoryEvent;
	import watercolor.events.LayerEvent;
	import watercolor.events.StrokeElementEvent;
	import watercolor.managers.HistoryManager;
	import watercolor.models.WaterColorModel;


	/**
	 * The WatercolorContext class defines the initial model, view and command
	 * mappings that are default to the Watercolor library. Additional
	 * application-specific mappings should be created by extending this class.
	 */
	public class WatercolorContext extends Context
	{
		/**
		 * Constructs a new WatercolorContext.
		 *
		 * @param contextView The root view node of the context. The context will listen for ADDED_TO_STAGE events on this node
		 * @param autoStartup Should this context automatically invoke it's <code>startup</code> method when it's <code>contextView</code> arrives on Stage?
		 */
		public function WatercolorContext( contextView:DisplayObjectContainer = null, autoStartup:Boolean = true )
		{
			super( contextView, autoStartup );
		}


		/**
		 * The Startup Hook where default Watercolor mappings are established.
		 */
		override public function startup():void
		{
			//History Commands
			commandMap.mapEvent( HistoryEvent.UNDO, HistoryUndoCommand );
			commandMap.mapEvent( HistoryEvent.REDO, HistoryRedoCommand );

			//Elements Commands
			commandMap.mapEvent( ElementEvent.TRANSFORM, TransformElementsCommand, ElementEvent );
			commandMap.mapEvent( ElementEvent.POSITION_CHANGE, ChangeElementPositionCommand, ElementEvent );
			commandMap.mapEvent( ElementEvent.ADD, AddElementCommand );
			commandMap.mapEvent( ElementEvent.REMOVE, RemoveElementCommand );

			//Grouping Commands
			commandMap.mapEvent( GroupingEvent.GROUP, GroupElementsCommand, GroupingEvent );
			commandMap.mapEvent( GroupingEvent.UNGROUP, UnGroupElementsCommand, GroupingEvent );

			//Layers Commands
			commandMap.mapEvent( LayerEvent.ADD, AddLayerCommand, LayerEvent );
			commandMap.mapEvent( LayerEvent.REMOVE, RemoveLayerCommand, LayerEvent );
			commandMap.mapEvent( LayerEvent.PROPERTY_CHANGE, ChangeLayerPropertiesCommand, LayerEvent );
			commandMap.mapEvent( LayerEvent.POSITION_CHANGE, ChangeLayerPositionCommand, LayerEvent );

			// Strokes and Fills
			commandMap.mapEvent( FillElementEvent.FILL, FillElementCommand );
			commandMap.mapEvent( StrokeElementEvent.STROKE, StrokeElementCommand );
			
			//Mediators
			mediatorMap.mapView( Rect, ElementMediator, Element );
			mediatorMap.mapView( Ellipse, ElementMediator, Element );
			mediatorMap.mapView( Group, GroupMediator );
			mediatorMap.mapView( Workarea, WorkareaMediator );

			//Singletons
			injector.mapSingleton( WaterColorModel );
			
			// Keyboard Shortcuts
			commandMap.mapEvent( KeyboardEvent.KEY_DOWN, KeyboardCommand );

			// call super after context startup is complete
			super.startup();
		}


		/**
		 * The Shutdown Hook, available for context cleanup.
		 */
		override public function shutdown():void
		{
			// call super after context shutdown is complete
			super.shutdown();
		}
	}
}