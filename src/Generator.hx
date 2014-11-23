import sys.FileSystem.*;
import sys.io.*;
import data.*;
import geo.*;

using StringTools;
/**
	This is a quick and dirty static pages generator that I'm using for this blog.
	As you will realize, it was hacked in together in a couple of hours and it's not ready to be released as a separate library.
 **/
class Generator
{
	public static inline var POSTS_PER_PAGE = 2;

	static function main()
	{
		var metas = [];
		function handleMarkdown(dir:String, file:String)
		{

			var path = dir != null ? 'articles/$dir/$file' : 'articles/$file';
			var post = md.PostRenderer.fromMarkdown(File.getContent(path));
			trace('here',post);
			post.meta.path = '$dir/${file.substr(0,file.length-3)}';
			if (dir != null)
				metas.push(post.meta);

			//for each post, expand
			expandPost(post);
		}

		function recursedir(dir:String)
		{
			if (!exists('www/$dir')) createDirectory('www/$dir');
			for (file in readDirectory('articles/$dir'))
			{
				var path = 'articles/$dir/$file';
				if (isDirectory(path))
				{
					recursedir('$dir/$file');
				} else if (file.endsWith('.md')) {
					handleMarkdown(dir,file);
				}
			}
		}
		// collect all posts
		for (file in readDirectory('articles'))
		{
			if (isDirectory('articles/$file'))
				recursedir(file);
			else if (file.endsWith('.md'))
				handleMarkdown(null,file);
		}
		// sort by date desc
		metas.sort(function(v1,v2) return Reflect.compare(v2.date.date,v1.date.date));
		// create main page + archive
		expandMult('Introduction text',metas,'www/index');
		// create tag pages
	}

	private static function expandPost(post:Post)
	{
		var dest = 'www/${post.meta.path}.html';
		var file = File.write(dest,false);
		file.writeString(new view.HtmlHeader().setData({
			title: post.meta.title + ' - codegen.ml',
			author: post.meta.author,
			description: post.meta.description,
			keywords: post.meta.tags
		}).execute());
		file.writeString(new view.Header().setData({
			featured: null
		}).execute());
		file.writeString(new view.SinglePost().setData({
			title: post.meta.title,
			date: post.meta.date.format('%b %d, %Y'),
			tags: post.meta.tags,
			description: post.meta.description,
			contents: post.contents
		}).execute());
		file.writeString(new view.Footer().setData({}).execute());
	}

	private static function expandMult(featured:String, posts:Array<PostMeta>, dest:String)
	{
	}
}
