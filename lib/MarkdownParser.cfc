component
	output = false
	hint = "I parse Markdown syntax into HTML."
	{

	// I initialize the component.
	public any function init( required string input ) {

		// I determine if the markdown content has been parsed. This will allow us to 
		// return cached HTML content if toHtml() is called multiple times.
		isParsed = false;

		// Store the raw markdown content and the pased HTML content - no work is 
		// actually done until the toHtml() method is invoked.
		markdownContent = input;		
		htmlContent = "";

		// Set up some easy-to-read refernces to character formations.
		linebreak = chr( 10 );
		doubleLinebreak = ( linebreak & linebreak );

		// Cache the pattern/matcher classes for static method references.
		patternClass = createObject( "java", "java.util.regex.Pattern" );
		matcherClass = createObject( "java", "java.util.regex.Matcher" );

		return( this );

	}


	// ---
	// STATIC METHODS.
	// ---


	// I parse the given Markdown content and return the resultant HTML.
	public string function parse( required string input ) {

		var parser = new MarkdownParser( input );

		return( parser.toHtml() );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I return the HTML produced by the current markdown content.
	public string function toHtml() {

		// Return cached content if available.
		if ( isParsed ) {

			return( htmlContent );

		}

		// Start out with the raw input.
		htmlContent = trim( markdownContent );

		normalizeLineBreaks();
		normalizeEmptyLines();
		normalizeTabs();
		normalizeBlockquotes();

		// applyReferenceLinks();



		// extractReferenceLinks();

		var lines = getLinesOfContent();

		writeDump(lines);
		abort;


		isParsed = true;

		return( htmlContent );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	private void function applyReferneceLink(
		required string name,
		required string value
		) {



	}


	private void function applyReferenceLinks() {

		var referenceLinks = extractReferenceLinks();

		for ( var linkName in referneceLinks ) {

			applyReferneceLink( linkName, referneceLinks[ linkName ] );

		}

	}


	// I return a Java pattern matcher for the given content and given Java regular
	// expression pattern.
	private any function createMatcher(
		required string content,
		required string pattern
		) {

		var matcher = patternClass
			.compile( javaCast( "string", pattern ) )
			.matcher( javaCast( "string", content ) )
		;

		return( matcher );

	}


	// I create a Java StringBuffer.
	private any function createStringBuffer() {

		return(
			createObject( "java", "java.lang.StringBuffer" ).init()
		);

	}


	// I extract and return the reference link, leaving the html content free of rerence 
	// links. The reference links are the bibliography-style links in the format of:
	// --
	// [1]: http://www.bennadel.com
	// [ben-nadel]: http://www.bennadel.com
	// --
	// Currently, the only resticted characters in the link "name", are "[", "]", ":", "\n".
	private struct function extractReferenceLinks() {

		var matcher = createMatcher( htmlContent, "(?m)^\[([^\[\]\n:]+)\]:([^\n]*)\n?" );
		var buffer = createStringBuffer();

		// I hold the key-based dictionary for the links.
		var referenceLinks = {};

		while ( matcher.find() ) {

			// Since we are extracing the links, leave out replacement content.
			matcher.appendReplacement( buffer, javaCast( "string", "" ) );

			var linkName = lcase( matcher.group( javaCast( "int", 1 ) ) );
			var linkValue = trim( matcher.group( javaCast( "int", 2 ) ) );

			referenceLinks[ linkName ] = linkValue;

		}

		matcher.appendTail( buffer );

		htmlContent = trim( buffer.toString() );

		return( referenceLinks );

	}


	// I return all the lines in the current content. This does not include the linefeed
	// at the end of the lines.
	private array function getLinesOfContent() {

		return(
			reMatchAll( htmlContent, "(?m)^[^\n]*" )
		);

	}


	// Blockquotes can be lazy, meaning that the ">" character is only on the first line 
	// of the block of text. Let's remove any line breaks from that text to keep the 
	// blockquote item on a single line.
	private void function normalizeBlockquotes() {

		var matcher = createMatcher( htmlContent, "(?m)^>[^\n]*(\n[^>\n][^\n]+)+" );
		var buffer = createStringBuffer();

		while ( matcher.find() ) {

			matcher.appendReplacement(
				buffer,
				quoteReplacement(
					reReplaceAll( matcher.group(), "\n", " " )
				)
			);

		}

		matcher.appendTail( buffer );

		htmlContent = buffer.toString();

	}


	// I make sure that all white-space-only lines have no content (ie, that they are
	// only new-lines).
	private void function normalizeEmptyLines() {

		// Strip out any non-linebreak white space.
		htmlContent = reReplaceAll( htmlContent, "(?m)^[\s&&[^\n]]+\n", linebreak );

		// Collapse multiple line breaks into no-more than one.
		htmlContent = reReplaceAll( htmlContent, "(?m)^\n{2,}", doubleLinebreak );
		
	}


	// I convert all linebreaks in the HTML content into line-feeds.
	private void function normalizeLineBreaks() {

		htmlContent = reReplaceAll( htmlContent, "\r\n?", linebreak );
		
	}


	// I replace all tabs with spaces.
	private void function normalizeTabs() {

		// So that we don't have to execute too many replace actions, we're going to
		// search for strings of tabs, rather than one tab at a time. Then, we can 
		// replace them with (N x 4) spaces.
		var matcher = createMatcher( htmlContent, "\t+" );
		var buffer = createStringBuffer();

		while ( matcher.find() ) {

			var tabCount = len( matcher.group() );
			var spaces = repeatString( "    ", tabCount );

			matcher.appendReplacement( buffer, javaCast( "string", spaces ) );

		}

		matcher.appendTail( buffer );

		htmlContent = buffer.toString();

	}


	private string function quoteReplacement( required string pattern ) {

		return(
			matcherClass.quoteReplacement( javaCast( "string", pattern ) )
		);

	}


	// I return all the pattern matches in the given content.
	private array function reMatchAll(
		required string content,
		required string pattern
		) {

		var matches = [];
		var matcher = createMatcher( content, pattern );

		while ( matcher.find() ) {

			arrayAppend( matches, matcher.group() );

		}

		return( matches );

	}


	// I perform a Java regular-expression replace on the given content.
	private string function reReplaceAll(
		required string content,
		required string pattern,
		string replacement = "",
		boolean isQuoteReplacement = false
		) {

		// If desired, escape special characters in the replcaement text.
		if ( isQuoteReplacement ) {

			replacement = quoteReplacement( replacement );

		}

		return(
			javaCast( "string", content ).replaceAll(
				javaCast( "string", pattern ),
				javaCast( "string", replacement )
			)
		);

	}

}