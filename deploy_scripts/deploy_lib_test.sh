function test_cgi_script {
	cd apache/cgi-bin
	perl -w accept_form.pl name="Bill Jones" address="No fixed abode" | grep "<td>Bill Jones</td><td>No fixed abode</td>"
	CGI_STATUS=$?
	cd ../..
	if [ $CGI_STATUS -ne 0 ] ; then
		console_error "CGI script failed test, aborting"
		exit 1
	fi
}

function test_application_running {
	local error=0
	curl "http://127.0.0.1:80" | grep "<title>Sample App</title>"
	((error+=$?))
	curl "http://127.0.0.1:80/form.html" | grep "<legend>Sample Form</legend>"
	((error+=$?))
	curl "http://127.0.0.1:80/cgi-bin/accept_form.pl?name=Joe&address=None" | grep "<td>Joe</td><td>None</td>"
	((error+=$?))
	return $error
}