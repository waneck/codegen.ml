[date]: / "2014-11-23T20:49:49-0300"
[modified]: / "2014-12-10T02:03:49-0300"
[tags]: / "blog,server-side,weekend project"
[issue]: / "1"

# Hello, World!

Hello and welcome to my first try at blogging! I've been meaning to start a blog for at least
one year now, but never got the time to actually tackle this project.
However, I've been working on so many different projects that I'd like to share with you - both
the process of doing them and maybe debating my visions on the matters - that I had the motivation
to actually go through with this.

I am very inexperienced at writing blog posts, and I hope you guys will bear with me
until I get the gist. I am sure that this site will have a lot of flaws in this beginning and any help
or suggestion you have will be much appreciated. This is specially true since I designed and coded
this blog as part of a weekend project. And I'm not a web designer - even though I'm an enthusiast
of clean design. To make matters worse, I also decided to not use any of the blogging platforms available and roll my own.

## The blogging platform

Having quite a lot of options to choose, I ended up just rolling my own static content generator
from markdown files. My main reason to do this is that it's pretty straight-forward to get this option running -
the current code needed to get this going was around 300 LOC - and I can gain control of the features I want
to implement in the platform. I prefer things simple and manageable like that, and in my understanding
there's hardly a reason to use blogging platforms if you know markdown and git. Of course I could have
taken the time to make this simple static content generator into a blogging platform itself - but if you 
[actually look at the code](https://github.com/waneck/codegen.ml), you'll see that there's hardly enough
code to justify that. Also this would also mean writing the generator code with more care, which would
defeat the idea of a weekend project.

![Too many options, maybe I should roll my own:.max](data/choice-haxe.png)
-- The drama of options (from http://haxememes.tumblr.com)

## No comments!?

While this project evolved over the weekend, one of the things that bothered me the most was how to deal with
comments. Comments are tricky to get right, and I can't think of any blogging platform that actually got it right
in my point of view. Moreover -- this was originally a weekend project and I'd still like to maintain it like this.
Working on a comment system would easily surpass my own deadline, and getting it right (which would mean subscription,
mentioning, maybe an account system, etc) would take a lot of effort and go against the philosophy of this blog project.

Having said this, all the alternatives I found - like [disqus](http://disqus.com:nofollow) - didn't satisfy me.
Moreover - I don't think it really achieves its goal very well. My second thought was to use some site like [hacker news](https://news.ycombinator.com/)
for comments. This still feels like a good idea, but it seems that some kinds of comments that would be fine
for the website would be frowned upon in the hacker news community. 

After some thought, it seems to me that the best way to deal with comments is inspired with how [@skial](http://twitter.com/skial)
does it with his Haxe-related news site, [haxe.io](http://haxe.io) and use [github](https://github.com/skial/haxe.io).
This is still very experimental for me, but I think it's a very nice idea. Since we're already using git as the platform
to publish content, it makes sense that we use github to discuss this content. Not only this - but you can actually add comments
inline if you wish.

So here's how this will work: every time I create a post, I'll create an issue and associate its id (`//TODO: add hook`). The post will
contain a link to the issue where you'll be able to comment, subscribe or mention in other github projects.

I wonder how well this will work. Feedback will be appreciated :)

## Naming

The name is inspired by one of [Haxe's source code file](https://github.com/HaxeFoundation/haxe/blob/development/codegen.ml).
Ever since I started to be close to Haxe's development, I found it funny that every time an OCaml source code file name was mentioned,
it was misinterpreted as a link because of the `.ml` TLD. When the `.ml` TLD started selling its domain names, I quickly bought one of
the Haxe source code file names. Why codegen? I thought at first about buying `gencommon`, 
[but I'd rather not associate too much with it :P](http://haxememes.tumblr.com/post/87036011589/simn-but-you-should-get-the-hell-out-of).
Also for the kind of work I usually do - in compilers and meta-compilation - it seems an appropriate title for the blog.

The TLD for `.ml` however does have its bumps, and it seems to be frozen in limbo right now - as in it's mine, can't be registered (again), but isn't
acessible for me either. To make things safer, `codegenml.com` will be the official domain for my blog, and `condegen.ml` will redirect to here
once it's released somehow.

## Some server details for the geeks
### Gooble-gobble

Many of you may not know this about me, but I like server-side. I love writing backend code, tools and
understanding and optimizing the low-level interactions that happen with the data flow.
For my job, I've coded some tools that make servers very easy to configure and keep in sync. We call it `gooble-gobble`
as a [reference](https://www.youtube.com/watch?v=bBXyB7niEc0) to the fact that once it's run, it adds some measures that
only allows the server to be accessed through our own servers.
Sadly these tools like `gooble-gobble` will hardly ever be released as open-source, as they are quite specific to our needs and
setup - with specific server configurations. I'm a big fan of [convention over configuration](http://en.wikipedia.org/wiki/Convention_over_configuration).

Anyway the good part of `gooble-gobble` is that in less than one minute I can configure a secure webserver - with
neko (tora) and php configured.
As with many of our projects, there's already code there to deal with git hooks - which make the server update itself
every time a specific branch is pushed into a main repository.

It will also deal with optimization of static content, if requested to do so. Since I'm running this blog on an experimental
base, I've enabled all the optimizations I've coded. They include:

 * Embedding small images from `<img>` tags or `url()` codes in css using base64 encode
 * Minifying all served javascript content using [uglifyjs](https://github.com/mishoo/UglifyJS)
 * Minifying all served css
 * Pre-gzipping all text content - using the best compression possible (in the case, `advdef`).
 * Optimizing all images

### Specs
I've chosen to host this site on a very tiny server. Mainly as an experiment, but also because I believe it's
all I really need to host this blog - especially due to its static nature. *(Also because I've got plenty of
servers like these bought)*. So we're running under a 128MB virtual machine with a RAID-10 of SSDs, OpenVZ,
Ubuntu 14.04 and nginx.
Of course one of the big reasons for me not to worry too much about the server's lack of power is due to
[cloudflare](https://www.cloudflare.com). The fact that the content is 100% pre-generated, and it's running
on a RAID-10 of SSDs also helps in that sense!
