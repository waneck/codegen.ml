package view;

@:includeTemplate('htmlheader.html')
class HtmlHeader extends erazor.macro.SimpleTemplate<{
	var title:String;
	var author:String;
	var description:String;
	var keywords:Array<String>;
}>
{
}
