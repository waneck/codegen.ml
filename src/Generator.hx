import sys.FileSystem.*;
import sys.io.*;

using StringTools;
/**
	This is a quick and dirty static pages generator that I'm using for this blog.
	As you will realize, it was hacked in together in a couple of hours and it's not ready to be released as a separate library.
 **/
class Generator
{
	static function main()
	{
		// collect all posts
		for (post in readDirectory('articles/blog'))
		{
			if (!post.endsWith('.md')) continue;
			trace('here',post);
			var mdown = md.PostRenderer.fromMarkdown(File.getContent('articles/blog/$post'));
			trace('here');
			trace(mdown);
		}
		// for each post, expand
		// for each
	}
}
