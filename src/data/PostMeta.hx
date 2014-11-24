package data;
import geo.*;

class PostMeta
{
	public var author:Null<String>;
	public var title:Null<String>;
	public var description:Null<String>;
	public var tags:Array<Tag>;
	public var date:Null<TzDate>;
	public var modified:Null<TzDate>;
	public var path:String;

	public var githubIssue:Null<Int>;

	public function new()
	{
		this.tags = [];
	}
}
