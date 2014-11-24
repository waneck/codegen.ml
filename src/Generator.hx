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
	public static inline var POSTS_PER_PAGE = 25;

	static function main()
	{
		var metas = [];
		function handleMarkdown(dir:String, file:String)
		{

			var path = dir != null ? 'articles/$dir/$file' : 'articles/$file';
			var post = md.PostRenderer.fromMarkdown(File.getContent(path));
			post.meta.path = dir != null ? '$dir/${file.substr(0,file.length-3)}' : file.substr(0,file.length-3);
			if (dir != null && post.meta.date != null)
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

		if (Sys.getEnv('NO_MULT') != null)
			return;

		// collect all posts
		for (file in readDirectory('articles'))
		{
			if (isDirectory('articles/$file'))
				recursedir(file);
			else if (file.endsWith('.md') && file != 'index.md')
				handleMarkdown(null,file);
		}
		// sort by date desc
		metas.sort(function(v1,v2) return Reflect.compare(v2.date.date,v1.date.date));
		// create main page + archive
		var introText = md.PostRenderer.fromMarkdown(File.getContent('articles/index.md')).contents;
		expandMult(introText,'Home', metas,'index');

		// create tag pages
		var tags = new Map();
		for (meta in metas)
		{
			for (tag in meta.tags)
			{
				var t = tags[tag.name];
				if (t == null)
				{
					tags[tag.name.toLowerCase()] = t = [];
				}
				t.push(meta);
			}
		}
		if (!exists('www/tags')) createDirectory('www/tags');
		for (tag in tags.keys())
		{
			expandMult("Posts tagged '" + tag + "'",'Tag $tag', tags[tag],'tags/${new Tag(tag).normalized}');
		}
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
			date: post.meta.date != null ? post.meta.date.format('%b %d, %Y') : null,
			tags: post.meta.tags,
			description: post.meta.description,
			contents: post.contents
		}).execute());
		file.writeString(new view.Footer().setData({
			curaddr: post.meta.path + '.html'
		}).execute());
		file.close();
	}

	private static function expandMult(featured:String, title:String, posts:Array<PostMeta>, dest:String)
	{
		var numPages = Std.int(Math.ceil(posts.length / POSTS_PER_PAGE));
		var pages = [ for (i in 0...numPages) { num:i, addr: i == 0 ? '/$dest.html' : '/$dest-$i.html' } ];
		for (i in 0...numPages)
		{
			var file = File.write('www/$dest' + (i == 0 ? '' : '-$i') + '.html');
			file.writeString(new view.HtmlHeader().setData({
				title: title + (i != 0 ? ' - page $i' : '') + ' - codegen.ml',
				author: null,
				description: null,
				keywords: null,
			}).execute());
			file.writeString(new view.Header().setData({
				featured: featured
			}).execute());
			file.writeString(new view.PostList().setData({
				posts:[ for (post in posts.slice(i*POSTS_PER_PAGE, (i+1)*POSTS_PER_PAGE)) {
					address: '/${post.path}.html',
					title: post.title,
					date: post.date != null ? post.date.format('%b %d, %Y') : null,
					tags: post.tags,
					description: post.description
				} ],
				pages:pages,
				currentPage:i,
				total: posts.length,
			}).execute());
			file.writeString(new view.Footer().setData({
				curaddr: dest + (i == 0 ? '' : '-$i') + '.html'
			}).execute());
			file.close();
		}
	}
}
