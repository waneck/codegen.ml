package view;
import data.*;
import geo.*;

@:includeTemplate('postlist.html')
class PostList extends erazor.macro.SimpleTemplate<{
	var posts:Array<{
		var address:String;
		var title:String;
		var date:String;
		var tags:Array<Tag>;
		var description:String;
	}>;
	var pages:Array<{ num:Int, addr:String }>;
	var currentPage:Int;
	var total:Int;
}>
{
}
