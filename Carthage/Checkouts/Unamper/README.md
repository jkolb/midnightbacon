# Unamper

#### XHTML, HTML, and XML Entity Decoder

    let string = "&quot;Peas &amp; Carrots&quot;"
	let unescapedString = string.unescapeEntities()
	print(unescapedString) // "Peas & Carrots"
