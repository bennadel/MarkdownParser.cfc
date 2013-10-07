
<cfsavecontent variable="content">
	
# MarkdownParser.cfc - ColdFusion Markdown Parser

by [Ben Nadel][bennadel] (on [Google+][google-plus])

I want to try and build a Markdown parser in ColdFusion (that doesn't defer
to a Java library for the actual parsing).

## Inspiration
   
The following libraries formed much of what I put together in my ColdFusion 
component for Markdown parsing.

* [Marked by Christopher Jeffrey][4].
* Showdown by John Fraser.
* [Parsedown by Emanuil Rusev][5].


[bennadel]: http://www.bennadel.com
[google-plus]: https://plus.google.com/108976367067760160494?rel=author
[3]: http://daringfireball.net/projects/markdown/
[4]: https://github.com/chjj/marked
[5]: https://github.com/erusev/parsedown

</cfsavecontent>


<cfset parser = new lib.MarkdownParser( content ) />

<cfset parser.toHtml() />


