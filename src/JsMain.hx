import js.JQuery;

class JsMain
{
	static function main()
	{
		var gissue = ~/github.com\/([^\/]+)\/([^\/]+)\/issues\/(\d+)/;
		new JQuery('.comment a').each(function() {
			var cur = JQuery.cur;
			var addr = cur.attr('href');
			trace('here');
			trace(addr);
			if (gissue.match(addr))
			{
				var user = gissue.matched(1),
					repo = gissue.matched(2),
					inum = gissue.matched(3);
				var apiaddr = 'https://api.github.com/repos/$user/$repo/issues/$inum';
				trace('matched',apiaddr);
				var http = new haxe.Http(apiaddr);
				http.async = true;
				http.onData = function(data) {
					trace('received data',data);
					var json = haxe.Json.parse(data);
					var ncomments:Int = json.comments;
					trace(ncomments);
					if (ncomments != null)
					{
						if (ncomments > 0)
						{
							cur.siblings('i').removeClass('fa-comment').addClass('fa-comments');
							cur.text('$ncomments comments. Click here to head over to Github and comment!');
						} else {
							cur.text('Click here to be the first to comment on this post at Github!');
						}
					}
				};
				http.request(false);
			}
		});
	}
}
