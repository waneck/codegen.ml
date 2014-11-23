package md;
import Markdown;
import markdown.AST;
import data.*;
import geo.*;

using StringTools;

class PostRenderer extends markdown.HtmlRenderer
{
	var meta:PostMeta;
	var inQuote:Bool;
	var afterQuote:Bool;

	var inParagraph:Bool;
	var inTitle:Bool;

	function new(meta:PostMeta)
	{
		super();
		this.meta = meta;
		inQuote = false;
		afterQuote = false;
		inTitle = inParagraph = false;
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
				buffer.add('<figcaption>${txt.substr(2)}</figcaption>');
				return;
			}
		}

		if (inTitle && meta.title == null)
		{
			meta.title = text.text;
			return;
		}

		if (inParagraph)
		{
			if (meta.description == null)
				meta.description = text.text;
			else
				meta.description = (meta.description + " " + text.text).trim();
		}
		super.visitText(text);
	}

	override public function visitElementBefore(element:ElementNode):Bool
	{
		//blockquote handling
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

		switch(element.tag.toLowerCase())
		{
			case 'img' if (element.isEmpty()):
				var src = element.attributes['src'];
				var alt = element.attributes['alt'];
				if (src != null)
				{
					if (alt == null) alt = '';
					if (src.indexOf('http://player.vimeo.com') >= 0)
					{
						buffer.add('\n<div class="media"><iframe src="$src" alt="$alt" ></iframe></div>');
						return false;
					} else if (src.indexOf('http://www.youtube.com/embed') >= 0) {
						buffer.add('\n<div class="media"><iframe src="$src" alt="$alt"></iframe></div>');
						return false;
					}
				}

				if (alt != null)
				{
					var split = alt.split(':'),
							def = split.pop();
					switch(def)
					{
						case '.max':
							element.attributes['alt'] = split.join(':');
							element.attributes['class'] = 'img-max';
					}
				}
			case 'p' if (meta.description == null || meta.description == ''):
				inParagraph = true;
				element.attributes['class'] = 'featured';
			case 'h1':
				inTitle = true;
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
			case _ if(afterQuote):
				checkClose();
		}

		switch (element.tag.toLowerCase())
		{
			case 'p':
				inParagraph = false;
			case 'h1':
				inTitle = false;
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

		var meta = new PostMeta();
		var renderer = new PostRenderer(meta);
		var contents = renderer.render(blocks);
		renderer.checkClose();
		consumeLinks(meta,document.refLinks);

		return { meta:meta, contents:contents };
	}

	public static function consumeLinks(meta:PostMeta, links:Map<String,Link>)
	{
		inline function getData(name:String) return if (links.exists(name)) links[name].title; else null;
		inline function getDate(name:String) return if (links.exists(name)) TzDate.fromIso(links[name].title); else null;

		meta.author = getData('author');
		if (links.exists('tags'))
			for (tag in links['tags'].title.split(','))
				meta.tags.push(tag);
		meta.date = getDate('date');
		meta.modified = getDate('modified');
	}
}
