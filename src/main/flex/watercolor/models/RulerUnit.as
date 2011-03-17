package watercolor.models
{
	public class RulerUnit
	{
			
		public var ppu:Number; // pixels per unit
		public var unitName:String;
		public var unitAbbr:String;
		public var precision:int; // power of 10, used to determine how values should be rounded
			
		public function RulerUnit(ppu:Number = 1, unitName:String = "Pixels", unitAbbr:String = "px", precision:int = 0)
		{
			this.ppu = ppu;
			this.unitName = unitName;
			this.unitAbbr = unitAbbr;
			this.precision = precision;
		}
	}
}