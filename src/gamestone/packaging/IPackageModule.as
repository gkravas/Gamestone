package gamestone.packaging {
	
	public interface IPackageModule	{
		
    	function getContent():XML
    	function getClass(id:String):Class
	}
}