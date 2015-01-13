module OperationsHelper

	def make_kind_presentable(kind_str)
		kind_str.split('_').collect{|w| w.capitalize}.join(' ')
	end


end
