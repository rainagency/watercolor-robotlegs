package watercolor.models.vo
{
	import watercolor.commands.vo.PropertyVO;
	import watercolor.elements.Layer;


	/**
	 * Container for any changes to be made to a Layer
	 *
	 * @author Sean Thayne
	 */
	public class LayerPropertiesVO
	{
		/**
		 * Layer Name
		 */
		public var name:String;


		/**
		 * Layer Color
		 */
		public var color:uint;


		/**
		 * Layer Visisibility
		 */
		public var visible:Boolean;


		/**
		 * Boolean describing if these changes should be added to the history manager.
		 */
		public var addToHistory:Boolean = true;


		/**
		 * Return a VO of a Layer's properties.
		 *
		 * Usefull for a starting point for changes.
		 *
		 * @param layer Layer to copy properties from.
		 *
		 * @return a VO of a Layer's properties.
		 */
		public static function createFromLayer( layer:Layer ):LayerPropertiesVO
		{
			var vo:LayerPropertiesVO = new LayerPropertiesVO();

			vo.name = layer.name;
			vo.color = layer.color;
			vo.visible = layer.visible;


			return vo;
		}


		/**
		 * Clone this Object.
		 *
		 * @return a cloned copy of this VO.
		 */
		public function clone():LayerPropertiesVO
		{
			var vo:LayerPropertiesVO = new LayerPropertiesVO();

			vo.name = name;
			vo.color = color;
			vo.visible = visible;

			return vo;
		}


		/**
		 * Packs a PropertyVO for WaterColor to execute.
		 *
		 * @param targetLayer Layer to modify.
		 *
		 * @return A PropertVO containing all the changes that need to happen.
		 */
		public function createPropertyExecuteVO( targetLayer:Layer ):PropertyVO
		{
			var propertyVO:PropertyVO = new PropertyVO();
			propertyVO.element = targetLayer;
			propertyVO.originalProperties = {};
			propertyVO.newProperties = {};

			if( name != targetLayer.name )
			{
				propertyVO.originalProperties[ 'name' ] = targetLayer.name;
				propertyVO.newProperties[ 'name' ] = name;
			}

			if( color != targetLayer.color )
			{
				propertyVO.originalProperties[ 'color' ] = targetLayer.color;
				propertyVO.newProperties[ 'color' ] = color;
			}

			if( visible != targetLayer.visible )
			{
				propertyVO.originalProperties[ 'visible' ] = targetLayer.visible;
				propertyVO.newProperties[ 'visible' ] = visible;
			}

			return propertyVO;

		}
	}
}