package watercolor.controller.mediators
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.managers.CursorManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	import spark.effects.Fade;
	import spark.events.ElementExistenceEvent;
	import spark.primitives.Rect;
	
	import watercolor.assets.cursors.HandClosed_cursor;
	import watercolor.assets.cursors.HandOpen_cursor;
	import watercolor.assets.cursors.ZoomIn_cursor;
	import watercolor.assets.cursors.ZoomOut_cursor;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.TransformVO;
	import watercolor.elements.Element;
	import watercolor.elements.Layer;
	import watercolor.elements.TextGroup;
	import watercolor.elements.components.Workarea;
	import watercolor.events.EditContourLayerEvent;
	import watercolor.events.ElementEvent;
	import watercolor.events.IsolationEvent;
	import watercolor.events.IsolationLayerEvent;
	import watercolor.events.LayerTransformEvent;
	import watercolor.events.TransformLayerEvent;
	import watercolor.events.WorkareaEvent;
	import watercolor.models.WaterColorModel;
	import watercolor.type.WorkareaCursorType;
	import watercolor.utils.CoordinateUtils;
	import watercolor.utils.ExecuteUtil;
	import watercolor.utils.LayerUtil;
	import watercolor.utils.MatrixUtil;
	import watercolor.utils.VisualElementUtil;
	
	
	/**
	 *
	 * @author mediarain
	 */
	public class WorkareaMediator extends Mediator
	{
		
		
		[Inject]
		/**
		 *
		 * @default
		 */
		public var workArea:Workarea;
		
		
		[Inject]
		/**
		 *
		 * @default
		 */
		public var model:WaterColorModel;
		
		
		/**
		 * Drag and select initial down point
		 */
		protected var initialDown:Point;
		
		
		/**
		 *
		 * @default
		 */
		protected var currentPoint:Point; // current point during drag and select
		
		
		/**
		 *
		 * @default
		 */
		protected var selectedElements:Vector.<Element>;
		
		protected var keyDown:Object = {};
		
		
		protected var pressPoint:Point;
		
		
		protected var pressPosition:Point;
		
		
		protected var pressAction:String; // WorkareaEvent.ZOOM or WorkareaEvent.PAN
		
		
		protected var selectionOn:Boolean = true;
		
		
		protected static const ZOOM_BOX_TOLERANCE:Number = 5;
		
		
		/**
		 * Fade Effect when removing the selection box.
		 * Matches Mac OS X selection box fade.
		 */
		protected var fadeEffect:Fade = new Fade();
		
		
		/**
		 * Rectangle that previews what will be selected
		 */
		protected var selectionDragRect:Rect = new Rect();
		
		/**
		 * Is Panning
		 */ 
		protected var _internal_isPanning:Boolean = false;
		
		protected function set isPanning(value:Boolean):void
		{
			if (_internal_isPanning != value)
			{
				_internal_isPanning = value;
				
				if (value)
				{
					pressAction = WorkareaEvent.PAN;
					
					// Change Hand Cursor to Closed Hand
					setClosedHandCursor();
				}
				else
				{
					// Handle if Spacebar is still in keydown state
					if (keyDown[ 32 ])
					{
						// Show Hand Cursor
						setOpenHandCursor();
					}
					else
					{
						CursorManager.removeAllCursors();   
					}
				}
			}
		}
		
		protected function get isPanning():Boolean
		{
			return _internal_isPanning;
		}
		
		/**
		 * Constructor
		 */
		public function WorkareaMediator()
		{
			super();
			
			initSelectionDragRect();
		}
		
		
		/**
		 * Register event listeners
		 */
		override public function onRegister():void
		{
			// set the dpi from the model
			workArea.dpi = model.workAreaDPI;
			
			// listen for when transformations are complete so that we can save them in the history manager
			eventMap.mapListener(workArea.selectionLayer.transformLayer, TransformLayerEvent.TRANSFORM_FINISH, transformationComplete);
			eventMap.mapListener(eventDispatcher, ElementEvent.TRANSFORM_COMPLETE, manualTransformationComplete);
			
			// listen for property changes on the viewport so that we can update the selection box on zoom and pan
			eventMap.mapListener(workArea.viewport, PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange);
			
			// Only listen for input if the workarea is editable
			if (workArea.editable)
			{
				// listen for mouse down on the document layer for drag and select or for zoom and pan
				eventMap.mapListener(workArea.documentLayer, MouseEvent.MOUSE_DOWN, documentPress, MouseEvent);
				
				// listen for keyboard events for keeping track which keys are pressed
				eventMap.mapListener(workArea.stage, KeyboardEvent.KEY_DOWN, keyPress, KeyboardEvent);
				eventMap.mapListener(workArea.stage, KeyboardEvent.KEY_UP, keyRelease, KeyboardEvent);
			}
			else
			{
				workArea.contentGroup.mouseChildren = false;
			}
			
			eventMap.mapListener(workArea.stage, Event.DEACTIVATE, stageDeactivate, Event);
			
			if (workArea.isolationLayer)
			{
				/*eventMap.mapListener(workArea.isolationLayer.exitBtn, MouseEvent.CLICK, handleExit);*/
				eventMap.mapListener(workArea.isolationLayer.trail, ElementExistenceEvent.ELEMENT_ADD, disableSelectionBox);
				eventMap.mapListener(workArea.isolationLayer.trail, ElementExistenceEvent.ELEMENT_REMOVE, disableSelectionBox);
				eventMap.mapListener(workArea.isolationLayer, IsolationEvent.ISOLATE, enterIsolation);
				eventMap.mapListener(workArea.isolationLayer, IsolationEvent.UNISOLATE, exitIsolation);
				eventMap.mapListener(workArea.isolationLayer, IsolationLayerEvent.GLYPH_COMBINED, isolationLayerSeperatedOrCombined);
				eventMap.mapListener(workArea.isolationLayer, IsolationLayerEvent.GLYPH_SEPERATED, isolationLayerSeperatedOrCombined);
				//eventMap.mapListener(workArea.isolationLayer, IsolationLayerEvent.EXIT_ISOLATION_MODE_LEVEL, isolationLayerExited);
				//eventMap.mapListener(workArea.isolationLayer, IsolationLayerEvent.EXIT_EDIT_CONTOUR_MODE_LEVEL, isolationLayerExited);
				eventMap.mapListener(workArea.isolationLayer, IsolationLayerEvent.EXIT_ISOLATION_MODE, isolationLayerExited);
				eventMap.mapListener(workArea.isolationLayer, EditContourLayerEvent.CONTOUR_HIDDEN, contourChanged);
				eventMap.mapListener(workArea.isolationLayer, EditContourLayerEvent.CONTOUR_UNHIDDEN, contourChanged);
			}
			
			// Redispatch Events to RL Framework
			eventMap.mapListener(workArea, WorkareaEvent.CURRENT_LAYER_CHANGED, redispatchEventToRL);
		}

		/**
		 * Redispatch Events to the RL Framework Event Bus
		 */ 
		protected function redispatchEventToRL(e:Event):void
		{
			dispatch(e);
		}
		
		/**
		 * Listen for property changes on the viewport in the work area
		 */
		protected function handlePropertyChange(event:PropertyChangeEvent):void
		{
			
			// if the viewport has been scrolled vertically or hizontally
			if(event.property == "verticalScrollPosition" || event.property == "horizontalScrollPosition")
			{
				
				// call the update properties function in the next update
				if(model.selectionManager.elements.length > 0)
				{						
					workArea.selectionLayer.transformLayer.update();
				}
			}
		}
		
		
		protected function documentPress(event:MouseEvent):void
		{
			workArea.setFocus();
			switch(true)
			{
				case keyDown[ 32 ]: // spacebar
					isPanning = true;
					break;
				case keyDown[ 90 ]: // Z 
					pressAction = WorkareaEvent.ZOOM;
					break;
				default:
					
					if(model.cursorMode == WorkareaCursorType.DEFAULT)
					{
						if(selectionOn)
						{
							// the local point in the selection layer where the user pressed the mouse button down
							initialDown = workArea.selectionLayer.globalToLocal(new Point(event.stageX, event.stageY));
							
							// Reset Selection Rect
							resetSelectionRect();
							
							// if the user hasn't clicked over an element or a selection box and if they are not holding the ctrl key
							if(!workArea.selectionLayer.transformLayer.isPointInsideOfElement(initialDown) && !event.ctrlKey)
							{
								// listen for mouse move and mouse up for drawing the drag and select rectangle
								workArea.stage.addEventListener(MouseEvent.MOUSE_MOVE, drawSelectionRect, false, 0, true);
								workArea.stage.addEventListener(MouseEvent.MOUSE_UP, removeSelectionRect, false, 0, true);
							}
							else
							{
								workArea.selectionLayer.removeElement(selectionDragRect);
							}
							
							// exit the function since we don't need any of the stuff below
							return;
						}
					}
					else if(model.cursorMode == WorkareaCursorType.ZOOM_IN || model.cursorMode == WorkareaCursorType.ZOOM_OUT)
					{
						pressAction = WorkareaEvent.ZOOM;
					}
					
					break;
			}
			
			
			// add global release to complete and remove listeners
			workArea.stage.addEventListener(MouseEvent.MOUSE_UP, documentRelease);
			workArea.stage.addEventListener(Event.MOUSE_LEAVE, documentRelease);
			// add global drag
			workArea.stage.addEventListener(MouseEvent.MOUSE_MOVE, documentDrag);
			// store the initial click point
			pressPoint = new Point(workArea.mouseX, workArea.mouseY);
			pressPosition = new Point(workArea.documentX, workArea.documentY);
			
			// TODO: determine the appropriate share of key and press events between tools
			//event.stopImmediatePropagation();
			event.updateAfterEvent();
		}
		
		
		/**
		 * Handler function for when a transformation is complete
		 */
		protected function transformationComplete(event:LayerTransformEvent):void
		{
			// create a new group command           
			var newCommand:GroupCommandVO = new GroupCommandVO();
			
			// go through each element and collect the new matrix as well as the old matrix
			for each(var element:Element in event.elements)  
			{						
				// create a transformationVO with the old and new matrices
				var trans:TransformVO = new TransformVO();
				trans.element = element;
				trans.newMatrix = element.transform.matrix.clone();
				trans.originalMatrix = event.transformations[ element ].matrix;
				
				// if it was indicated to restore the element to it's child matrix
				if (event.transformations[ element ].useChildMatrix)
				{
					trans.useChildMatrix = true;
				}
				
				newCommand.commands.push(trans);
			}
			
			if (newCommand.commands.length > 0)
			{
				eventDispatcher.dispatchEvent(new ElementEvent(ElementEvent.TRANSFORM, null, null, newCommand));
			}
		}
		
		protected function isolationLayerSeperatedOrCombined(event:LayerTransformEvent):void
		{
			transformationComplete(event);
			workArea.selectionLayer.transformLayer.unSelect();
		}
		
		
		/**
		 * Init Selection Drag Rect
		 */
		protected function initSelectionDragRect():void
		{
			// Init Fade Effect Properties for Selection Drag Rect
			fadeEffect.target = selectionDragRect;
			fadeEffect.alphaFrom = 1;
			fadeEffect.alphaTo = 0;
			fadeEffect.duration = 300;
			
			// Init SelectionDragRect Colors
			selectionDragRect.stroke = new SolidColorStroke(0x3399ff, 1);
			selectionDragRect.fill = new SolidColor(0x3399ff, .25);
		}
		
		
		/**
		 * Reset Selection Rect
		 */
		protected function resetSelectionRect():void
		{
			// Stop Effect if Playing
			handleEffectEnd();
			
			// Reset Properties
			selectionDragRect.width = 0;
			selectionDragRect.height = 0;
			selectionDragRect.x = 0;
			selectionDragRect.y = 0;
			
			// Add Selection Rect to SelectionLayer
			workArea.selectionLayer.addElement(selectionDragRect);
		}
		
		
		/**
		 * Listener function for the Mouse Move event
		 * Draws a rectangle on the selection layer to indicate the selection area
		 */
		protected function drawSelectionRect(event:MouseEvent):void
		{
			// set the current point
			currentPoint = workArea.selectionLayer.globalToLocal(new Point(event.stageX, event.stageY));
			
			// draw the rectangle to indicate the selection area
			selectionDragRect.alpha = 1;
			selectionDragRect.x = initialDown.x;
			selectionDragRect.y = initialDown.y;
			selectionDragRect.width = currentPoint.x - initialDown.x;
			selectionDragRect.height = currentPoint.y - initialDown.y;
			
			// Get Selected Elements when MouseMoves instead of on MouseUp.  This is what OS X does and is excellent.
			// Note: This currently slows down the selection process when the rectangle starts selecting 3 or more elements.  This
			//       should be optimized to provide better usability.
			
			//getElementsInSelectionRect(event);
		}
		
		
		/**
		 * Listener function the Mouse Up event
		 * Removes the selection rectangle and looks for all elements touched by the selection rectangle
		 * Updates the selection box based on the elements selected
		 */
		protected function removeSelectionRect(event:MouseEvent):void
		{
			// remove these listeners since we don't need them anymore
			workArea.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawSelectionRect);
			workArea.stage.removeEventListener(MouseEvent.MOUSE_UP, removeSelectionRect);
			
			// Finalize Selection
			getElementsInSelectionRect(event);
			
			// clear the selection layer of the drag and select rectangle
			fadeEffect.addEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
			fadeEffect.play();
		}
		
		
		/**
		 * Get Selected Elements While Dragging
		 */
		protected function getElementsInSelectionRect(event:MouseEvent):void
		{
			// reset the selected element
			selectedElements = new Vector.<Element>();
			
			var globalRelease:Point = new Point(event.stageX, event.stageY);
			
			// loop through the work area and find any elements that fall under the drag and select box
			if(workArea.isolationLayer && workArea.isolationLayer.elementLength() > 0 && !workArea.isolationLayer.contourMode)
			{
				findAllElements(workArea.isolationLayer.contentGroup, globalRelease, 0);
			}
			else
			{
				findAllElements(workArea.contentGroup as UIComponent, globalRelease, 0);
			}
			
			model.selectionManager.elements = selectedElements;
		}
		
		
		/**
		 * Handle SelectionDragRect Fade Effect End
		 * Removes the SelectionDragRect from SelectionLayer
		 */
		protected function handleEffectEnd(e:EffectEvent = null):void
		{
			fadeEffect.removeEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
			if(fadeEffect.isPlaying)
			{
				fadeEffect.stop();
			}
			
			// Remove Selection Box
			if(selectionDragRect.owner == workArea.selectionLayer)
			{
				workArea.selectionLayer.removeElement(selectionDragRect);
			}
		}
		
		
		protected function keyPress(event:KeyboardEvent):void
		{
			// When a user holds down a key, the KEY_DOWN event repeatedly gets called.  We return to prevent
			// the cursor from being set every time an event dispatches.
			if (keyDown[ event.keyCode ])
			{
				return;
			}
			
			// Handle Zoom In / Out with ctr-+
			if (event.ctrlKey && event.keyCode == 187) // +
			{
				workArea.zoomRelativeCenter();
				return;
			}
			else if (event.ctrlKey && event.keyCode == 189) // -
			{
				workArea.zoomRelativeCenter(true);
				return;
			}
			
			// Without the following if statement, if the user pressed "Ctr-Z" to undo, the keypress event for Z 
			// is detected, but the keyRelease event is never detected because the user still has the control key
			// down.
			if(event.ctrlKey == false)
			{
				keyDown[ event.keyCode ] = true;
				
				if (event.keyCode == 32) // Spacebar
				{
					// Show Hand Cursor
					setOpenHandCursor();
				}
				else if (event.keyCode == 90 && event.altKey == false) // Z
				{
					// Show Zoom In Cursor
					setZoomInCursor();
				}
				else if (event.keyCode == 90 && event.altKey == true) // Z
				{
					// Show Zoom Out Cursor
					// Note: Pressing the "option' key on a mac does not register a KeyboardEvent. 
					//       This means that if 'z' is pressed then 'option' is pressed, the 
					//       ZoomIn cursor will still be active but the mouse click will Zoom Out.
					setZoomOutCursor();
				}
			}
		}
		
		
		protected function keyRelease(event:KeyboardEvent):void
		{
			delete keyDown[ event.keyCode ];
			
			// Reset All Cursors
			if (!isPanning)
			{
				CursorManager.removeAllCursors();
			}
		}
		
		
		protected function stageDeactivate(event:Event):void
		{
			keyDown = {};
		}
		
		
		protected function documentDrag(event:MouseEvent):void
		{
			// find the new drag position and create the delta
			var dragPoint:Point = new Point(workArea.mouseX, workArea.mouseY);
			dragPoint = dragPoint.subtract(pressPoint);
			var scale:Number = workArea.documentScale;   
			
			switch(pressAction)
			{
				case WorkareaEvent.PAN:
					workArea.pan(pressPosition.x - dragPoint.x / scale, pressPosition.y - dragPoint.y / scale);
					break;
				case WorkareaEvent.ZOOM:
					var g:Graphics = workArea.selectionLayer.graphics;
					g.clear();
					
					if(dragPoint.x >= ZOOM_BOX_TOLERANCE && dragPoint.y >= ZOOM_BOX_TOLERANCE)
					{
						g.lineStyle(1, 0xFF0000, .25, true, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
						g.drawRect(pressPoint.x, pressPoint.y, dragPoint.x, dragPoint.y);
					}
					break;
			}
			
			
			event.updateAfterEvent();
		}
		
		
		protected function documentRelease(event:MouseEvent):void
		{
			workArea.stage.removeEventListener(MouseEvent.MOUSE_UP, documentRelease);
			workArea.stage.removeEventListener(Event.MOUSE_LEAVE, documentRelease);
			workArea.stage.removeEventListener(MouseEvent.MOUSE_MOVE, documentDrag);
			
			switch(pressAction)
			{
				case WorkareaEvent.PAN:
					isPanning = false;
					break;
				case WorkareaEvent.ZOOM:
					workArea.selectionLayer.blendMode = BlendMode.NORMAL;
					workArea.selectionLayer.graphics.clear();
					
					var releasePoint:Point = new Point(workArea.mouseX, workArea.mouseY);
					var localPress:Point = workArea.documentLayer.globalToLocal(workArea.localToGlobal(pressPoint));
					var localRelease:Point = workArea.documentLayer.globalToLocal(workArea.localToGlobal(releasePoint));
					releasePoint = releasePoint.subtract(pressPoint);
					localRelease = localRelease.subtract(localPress);
					
					if(releasePoint.x < ZOOM_BOX_TOLERANCE || releasePoint.y < ZOOM_BOX_TOLERANCE || event.altKey || model.cursorMode == WorkareaCursorType.ZOOM_OUT)
					{
						workArea.zoomPoint(localPress.x + localRelease.x / 2, localPress.y + localRelease.y / 2, (event.altKey || model.cursorMode == WorkareaCursorType.ZOOM_OUT));
					}
					else
					{
						workArea.zoomRect(localPress.x, localPress.y, localRelease.x, localRelease.y);
					}
					
					// only here because option/alt key doesn't dispatch a keybaord event
					if (event.altKey)
					{
						setZoomOutCursor(); 
					} else {
						setZoomInCursor();
					}
					break;
			}
			event.updateAfterEvent();
		}
		
		/**
		 * Clear current cursors and change to ZoomIn cursor
		 */ 
		protected function setZoomInCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(ZoomIn_cursor, 2, -6, -6);
		}
		
		/**
		 * Clear current cursors and change to ZoomOut cursor
		 */ 
		protected function setZoomOutCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(ZoomOut_cursor, 2, -6, -6);
		}
		
		/**
		 * Clear current cursors and change to Open Hand cursor
		 */ 
		protected function setOpenHandCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(HandOpen_cursor, 2, -10, -12);
		}
		
		/**
		 * Clear current cursors and change to Closed Hand cursor
		 */ 
		protected function setClosedHandCursor():void
		{
			CursorManager.removeAllCursors();
			CursorManager.setCursor(HandClosed_cursor, 2, -7, -7);
		}
		
		/**
		 * Finds all elements that are touched or contained in the rectangle that is passed in
		 * @param obj The display object that contains the children
		 * @param point The bottom right corner of the selection box of the area that we want to look in
		 * @param depth How many layers down do we look for elements
		 */
		protected function findAllElements(obj:UIComponent, point:Point, depth:int):void
		{
			findAllElementsRect(obj, point, depth);
		}
				
		/**
		 * Recursive function for find all elements in the work area
		 * Finds all elements that are touched or contained in the rectangle that is passed in
		 * @param obj The display object that contains the children
		 * @param point The bottom right corner of the selection box of the area that we want to look in
		 * @param depth How many layers down do we look for elements
		 * @param level Used by the recursive nature of the function and should typically not be changed
		 */
		private function findAllElementsRect(obj:UIComponent, point:Point, depth:int, level:int = 0):void
		{
			var comp:UIComponent;
			var newCurrent:Point;
			var newInitial:Point;
			var rect:Rectangle;
			var layer:Layer;
			
			// go through each child of the component 
			for(var x:int = 0; x < obj.numChildren; x++)
			{				
				comp = obj.getChildAt(x) as UIComponent;
				
				// make sure the component isn't null
				if(comp != null)
				{
					
					if(comp is Element && level == depth)
					{
						
						//This makes it so hidden layer's elements won't be selected.
						layer = LayerUtil.getLayer(comp);
						if(layer && (!layer.visible || !layer.mouseChildren))
							continue;
						
						// find the current point relative to the content group
						newCurrent = comp.parent.globalToLocal(point);
						
						// find the inital mouse down location relative to the content group
						newInitial = CoordinateUtils.localToLocal(workArea.selectionLayer, comp.parent, initialDown);
						
						// find the rectangle between the initial down and current location
						rect = new Rectangle(newInitial.x, newInitial.y, newCurrent.x - newInitial.x, newCurrent.y - newInitial.y);
						
						// if the rectangle's width is negative
						if(rect.width < 0)
						{
							
							// flip the x value between the top left and the bottom right
							rect.x = rect.bottomRight.x;
							
							// make sure the width isn't negative anymore
							rect.width = -rect.width;
						}
						
						// if the rectangle's height is negative
						if(rect.height < 0)
						{
							
							// flip the y value between the top left and the bottom right
							rect.y = rect.bottomRight.y;
							
							// make sure the height isn't negative anymore
							rect.height = -rect.height;
						}
						
						try
						{
							if(!VisualElementUtil.getColorBoundsRect(comp as Element, comp.parent, rect.intersection(comp.getBounds(comp.parent))).isEmpty() && comp.mouseEnabled)
							{
								// add the element to this collection
								selectedElements.push(comp);
							}
							
						}
						catch(exp:Error)
						{
							trace(exp.message);
						}
					}
					
					// if the element contains children then run this function again recursively
					if(comp.numChildren > 0 && level < depth)
					{
						findAllElementsRect(comp, point, depth, level + 1);
					}
				}
			}
		}
		
		
		/**
		 * Function to call when a contour has been changed while in the contour editor
		 */
		protected function contourChanged(event:EditContourLayerEvent):void
		{
			
			// store the propertyVO into the history manager
			ExecuteUtil.execute(event.commandVO);
			model.history.addCommand(event.commandVO);
		}
		
		
		/**
		 * protected function for entering isolation mode
		 */
		protected function enterIsolation(event:IsolationEvent):void
		{
			
			// make sure the element isn't null
			if(event.element && !(event.element is TextGroup))
			{
				
				// enter isolation mode for the element in the event
				workArea.isolationLayer.enterIsolation(event.element);
				
				// disable the content group on the workarea so that all children will be non mouse enabled
				// and for achieving the fade out effect
				workArea.contentGroup.alpha = 0.3;
				workArea.contentGroup.mouseChildren = false;
				
				// also disable the selection box
				workArea.selectionLayer.transformLayer.unSelect();
			}
		}
		
		
		/**
		 * protected function for exiting isolation mode
		 */
		protected function exitIsolation(event:IsolationEvent):void
		{
			
			// exit the current isolation mode instance
			workArea.isolationLayer.exitToLevel(0);
			
			// if there are no more layers in the isolation mode then turn the work area back on
			if(workArea.isolationLayer.elementLength() == 0)
			{
				
				workArea.contentGroup.alpha = 1;
				workArea.contentGroup.mouseChildren = true;
			}
			
			// also disable the selection box
			workArea.selectionLayer.transformLayer.unSelect();
		}
		
		protected function isolationLayerExited(event:IsolationLayerEvent):void
		{
			model.selectionManager.clear();
			
			// if there are no more layers in the isolation mode then turn the work area back on
			if(workArea.isolationLayer.elementLength() == 0)
			{				
				workArea.contentGroup.alpha = 1;
				workArea.contentGroup.mouseChildren = true;
			}
		}
		
		
		/**
		 * protected function that is called when elements are added to the isolation layer trail.
		 * This is called for disabeling the selection box when moving around to different layers in isolation mode
		 */
		protected function disableSelectionBox(event:ElementExistenceEvent):void
		{
			
			// disable the selection box
			workArea.selectionLayer.transformLayer.unSelect();
		}
		
		
		/**
		 * protected function that is called anytime a transformation is completed on an element
		 */
		protected function manualTransformationComplete(event:ElementEvent):void
		{
			
			// if in isolation mode then check if anything got moved so that items are no longer touching
			if(workArea.isolationLayer && workArea.isolationLayer.elementLength() > 0)
			{
				workArea.isolationLayer.checkIfAllElementsAreTouching();
			}
			
			// update the transformation layer
			//workArea.selectionLayer.transformLayer.update();
			//model.selection.updateSelection(false, true);
		}
	}
}
