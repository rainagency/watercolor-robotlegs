package watercolor.models
{
	public class RulerUnit
	{
			
		public var ppu:Number; // pixels per unit
		public var unitName:String;
		public var unitAbbr:String;
		public var precision:int; // power of 10, used to determine how values should be rounded
		public var dialSizeMin:Number; // minimum dial size for this unit
		public var dialSizeMax:Number; // maximum dial size for this unit
		public var dialSizeStep:Number; // dial size step for this unit
			
		public function RulerUnit(ppu:Number = 1, 
								  unitName:String = "Pixels", 
								  unitAbbr:String = "px", 
								  precision:int = 0, 
								  dialSizeMin:Number = 12, 
								  dialSizeMax:Number = 1728, 
								  dialSizeStep:Number = 12)
		{
			this.ppu = ppu;
			this.unitName = unitName;
			this.unitAbbr = unitAbbr;
			this.precision = precision;
			this.dialSizeMin = dialSizeMin;
			this.dialSizeMax = dialSizeMax;
			this.dialSizeStep = dialSizeStep;
		}
	}
}