package gamestone.utils {
	import mx.core.IFlexAsset;

	public interface IEmbededAssets {
		
		function getAsset(id:String):*;
		function getAssetClass(id:String):Class;
	}
}