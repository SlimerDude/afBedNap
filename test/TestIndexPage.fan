using afIoc
using afButter
using afBounce

internal class TestIndexPage : BedNapTest {

	@Inject	VisitorBookService?	bookService
	
	Void testIndexRendersOkay() {
		response := client.get(`/bednap`)
		verifyEq(response.statusCode, 200)
		
		h1	:= Element("h1")
		h1.verifyTextContains("Bed Nap Hotel")

		h2	:= Element("h2.panel-title")
		h20 := h2[0]
		h20.verifyTextEq("Add a comment")
		h2[1].verifyTextEq("Visitor Comments")
	}
	
	Void testListRendering() {
		bookService.clear

		bookService.add(Visitor() {
			it.id			= 1
			it.name			= "Emma"
			it.comment		= "Groovy"
			it.visitedOn	= DateTime.now
		})
		bookService.add(Visitor() {
			it.id			= 2
			it.name			= "of-9"
			it.comment		= "Awesome"
			it.visitedOn	= DateTime.now.plus(1sec)
		})
		
		response := client.get(`/bednap`)
		verifyEq(response.statusCode, 200)

		tableRows := Element("table > tbody > tr")
		tableRows.verifySizeEq(2)

		row1 := tableRows[0].find("td")
		row1[0].verifyTextEq("of-9")
		row1[2].verifyTextEq("Awesome")
		
		row2 := tableRows[1].find("td")
		row2[0].verifyTextEq("Emma")
		row2[2].verifyTextEq("Groovy")
	}

	Void testAddComment() {
		client.followRedirects.enabled = false
		client.get(`/bednap`)
		
		TextBox("#name").value = "Judge Dredd"
		TextBox("#comment").value = "I am the law!"	
		response := SubmitButton("[type=submit]").click
		
		verifyEq(response.statusCode, 303)
		verifyEq(response.headers.location, `/bednap`)
		
		verifyEq(bookService.all.size, 1)
		verifyEq(bookService.all[0].name, "Judge Dredd")
		verifyEq(bookService.all[0].comment, "I am the law!")
	}

	Void testDeleteComment() {
		visitor := bookService.add(Visitor() {
			it.id			= 1
			it.name			= "Emma"
			it.comment		= "Groovy"
			it.visitedOn	= DateTime.now
		})

		client.get(`/bednap`)
		
		verifyEq(bookService.all.size, 1)
		Element("table > tbody > tr").verifySizeEq(1)
		
		Link("#delete-${visitor.id}").click
		
		verifyEq(bookService.all.size, 0)
		Element("table > tbody > tr").verifySizeEq(0)		
	}
}
