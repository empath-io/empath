if (<%= obj_has_errors(@message) %> == 1) {
	<%= 
		if (obj_has_errors(@message) == 1)
				return_modal_js('dashboard',{:notice => @notice}).html_safe
		else
			''
		end
	%>
}
else {
	// if deactivation is successful, remove row from table
	$('tr#message-<%= @message.id %>').remove();
}
