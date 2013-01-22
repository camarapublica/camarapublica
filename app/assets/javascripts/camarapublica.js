function reply(object,id) {
	if(object=="project") {
		targetdiv="#comments"
		$("#nocomments").hide();
		$(".comment-btn").hide();
	}
	if(object=="comment") {
		targetdiv="#thread"+id
		$(targetdiv).show();
		$("#close-btn-"+id).show();
		$("#expand-btn-"+id).hide();
		$("#comment"+id).remove();
	}
	html="<form action='javascript:submitcomment(\""+object+id+"\")' style='margin:0' id='"+object+id+"'><div class='row'><div class='span10'><textarea name='text' class='span10'></textarea><input type='hidden' name='object' value='"+object+"'><input type='hidden' name='id' value='"+id+"'></div><div style='text-align:center' class='span2'><input type='submit' class='btn btn-success btn-large btn-reply' value='Comentar'></div></div></form>"
	$(targetdiv).prepend(html)
}
function submitcomment(formid) {
	form=$("#"+formid);
	console.log(form.serialize())
	$.ajax({
	  url: "/comment.js?"+form.serialize(),
	  dataType: "script"
	})
	return false;
}
function expandthread(id) {
	$("#thread"+id).show();
	$("#close-btn-"+id).show();
	$("#expand-btn-"+id).hide();
}
function closethread(id) {
	$("#thread"+id).hide();
	$("#close-btn-"+id).hide();
	$("#expand-btn-"+id).show();
	$("#comment"+id).remove();
}
function vote(object,id,score) {
	if(current_user>0) {
		$.ajax({
		  url: "/vote/"+object+"/"+id+"/"+score,
		  dataType: "script",
		  success: function(msg) {
		  	console.log(msg)
		  	if(msg=="ERROR") {
		  		alert("Error: Ya has votado")
		  	} else {
		  		$("#"+object+"score"+id).html(msg);
		  	}
		  }
		})
	} else {
		alert("para votar debes registrarte o iniciar sesión")
	}
}