package md;
import Markdown;
import markdown.AST;
import data.*;
import geo.*;

using StringTools;

class PostRenderer extends markdown.HtmlRenderer
{
	var meta:MetaPost;
	var inQuote:Bool;
	var afterQuote:Bool;
	function new(meta:MetaPost)
	{
		super();
		inQuote = false;
		afterQuote = false;
	}

	public function checkClose()
	{
		if (inQuote)
		{
			buffer.add('</figure>');
			inQuote = false;
			afterQuote = false;
		}
	}

	override public function visitText(text:TextNode):Void
	{
		if (inQuote && afterQuote)
		{
			var txt = text.text.trim();
			if (txt.startsWith('--'))
			{
				buffer.add('<figcaption>${txt}</figcaption>');
				return;
			}
		}
		super.visitText(text);
	}

	override public function visitElementBefore(element:ElementNode):Bool
	{
		switch (element.tag.toLowerCase())
		{
			case 'blockquote' if (!inQuote):
				inQuote = true;
				afterQuote = false;
				buffer.add('\n<figure>');
			case 'p' if (afterQuote):
			case _ if (afterQuote):
				checkClose();
			case _:
		}
		return super.visitElementBefore(element);
	}

	override public function visitElementAfter(element:ElementNode):Void
	{
		switch (element.tag.toLowerCase())
		{
			case 'blockquote':
				afterQuote = true;
			case 'p' if (!afterQuote):
			case _:
				checkClose();
		}
		super.visitElementAfter(element);
		// buffer.add('</${element.tag}>');
	}

	public static function fromMarkdown(markdown:String):Post
	{
		var document = new Document();
		// replace windows line endings with unix, and split
		var lines = ~/(\r\n|\r)/g.replace(markdown, '\n').split("\n");
		// parse ref links
		document.parseRefLinks(lines);
		// parse ast
		var blocks = document.parseLines(lines);

		var meta = new MetaPost();
		var renderer = new PostRenderer(meta);
		var contents = renderer.render(blocks);
		consumeLinks(meta,document.refLinks);

		return { meta:meta, contents:contents };
	}

	public static function consumeLinks(meta:MetaPost, links:Map<String,Link>)
	{
		inline function getData(name:String) return if (links.exists(name)) links[name].title; else null;
		inline function getDate(name:String) return if (links.exists(name)) TzDate.fromIso(links[name].title); else null;

		meta.author = getData('author');
		if (links.exists('tags'))
			for (tag in links['tags'].title.split(','))
				meta.tags.push(tag);
		meta.date = getDate('date');
		meta.modified = getDate('modified');

	// public var title:Null<String>;
	// public var description:Null<String>;
	}
}
