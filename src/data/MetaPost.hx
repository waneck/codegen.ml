package data;
import geo.*;

class MetaPost
{
	public var author:Null<String>;
	public var title:Null<String>;
	public var description:Null<String>;
	public var tags:Array<String>;
	public var date:Null<TzDate>;
	public var modified:Null<TzDate>;

	public function new()
	{
		this.tags = [];
	}
}
