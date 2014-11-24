package md;
import Markdown;
import markdown.AST;
import data.*;
import geo.*;

using StringTools;

class PostRenderer extends markdown.HtmlRenderer
{
	var meta:PostMeta;
	var inFigure:Bool;
	var afterFigure:Bool;

	var inParagraph:Bool;
	var inTitle:Bool;

	function new(meta:PostMeta)
	{
		super();
		this.meta = meta;
		inFigure = false;
		afterFigure = false;
		inTitle = inParagraph = false;
	}

	public function checkClose()
	{
		if (inFigure)
		{
			buffer.add('</figure>');
			inFigure = false;
			afterFigure = false;
		}
	}

	override public function visitText(text:TextNode):Void
	{
		if (inFigure && afterFigure)
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
			case 'blockquote' if (!inFigure):
				inFigure = true;
				afterFigure = false;
				buffer.add('\n<figure>');
			case 'img' if (!inFigure && element.isEmpty()):
				inFigure = true;
				afterFigure = true;
				buffer.add('\n<figure>');
			case 'p' if (afterFigure):
			case _ if (afterFigure):
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
			case 'p' if (!inFigure && !afterFigure && (meta.description == null || meta.description == '')):
				inParagraph = true;
				element.attributes['class'] = 'featured';
			case 'h1':
				inTitle = true;
			case 'a':
				var href = element.attributes['href'];
				if (href != null)
				{
					var data = href.split(':');
					if (data.length > 0)
					{
						switch (data.pop())
						{
							case 'nofollow':
								element.attributes['href'] = data.join(':');
								element.attributes['rel'] = 'nofollow';
							case _:
						}
					}
				}
			case _:
		}
		return super.visitElementBefore(element);
	}

	override public function visitElementAfter(element:ElementNode):Void
	{
		switch (element.tag.toLowerCase())
		{
			case 'blockquote':
				afterFigure = true;
			case 'p' if (!afterFigure):
			case _ if(afterFigure):
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
				meta.tags.push(tag.trim());
		meta.date = getDate('date');
		meta.modified = getDate('modified');
	}
}
