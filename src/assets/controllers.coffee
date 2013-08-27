controllers = angular.module 'ct5251', []
controllers.run ['$log', ($log) ->
	$log.debug "Initializing `ct5251` controllers module..."
]