package view;
import data.*;
import geo.*;

@:includeTemplate('post.html')
class SinglePost extends erazor.macro.SimpleTemplate<{
	var title:String;
	var date:UnixDate;
	var tags:Array<Tag>;
	var description:String;
	var contents:String;
}>
{
}
