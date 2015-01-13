class InternalController < ApplicationController

	def server_status
		render text: "OK"
	end


end
