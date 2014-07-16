$ ->
	$('#released_on')
	.datapicker(changeYear: true, yearRange: '1940:2014')
	$('#like input').click (event) -> 
		event.preventDefault()
		$.post(
			$('#like form').attr('action')
			(data) -> $('#like p').html(data).effect('highlight', colot: '#fcd')
		)