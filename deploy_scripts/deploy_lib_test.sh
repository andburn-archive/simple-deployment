function test_application_running {
	local error=0
	curl 127.0.0.1:80 | grep "<title>Sample App</title>"
	((error+=$?))
	curl 127.0.0.1:80/form.html | grep "<legend>Sample Form</legend>"
	((error+=$?))
	curl 127.0.0.1:80/cgi-bin/accept_form.pl?name=Joe&address=None | grep "<td>Joe</td><td>None</td>"
	((error+=$?))
	return error
}