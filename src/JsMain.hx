import js.JQuery;

class JsMain
{
	static function main()
	{
		var gissue = ~/github.com\/([^\/]+)\/([^\/]+)\/issues\/(\d+)/;
		new JQuery('.comment a').each(function() {
			var cur = JQuery.cur;
			var addr = cur.attr('href');
			if (gissue.match(addr))
			{
				var user = gissue.matched(1),
					repo = gissue.matched(2),
					inum = gissue.matched(3);
				var apiaddr = 'https://api.github.com/repos/$user/$repo/issues/$inum';
				var http = new haxe.Http(apiaddr);
				http.async = true;
				http.onData = function(data) {
					var json = haxe.Json.parse(data);
					var ncomments:Int = json.comments;
					if (ncomments != null)
					{
						var isMult = cur.is('.comment.mult a');
						if (isMult)
						{
							cur.text(ncomments +'');
						} else if (ncomments > 0) {
							cur.siblings('i').removeClass('fa-comment').addClass('fa-comments');
							var s = if (ncomments == 1) '' else 's';
							cur.text('$ncomments comment$s. Click here to head over to Github!');
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
