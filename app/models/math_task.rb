class MathTask
	
	def self.avg(arr)
		arr.inject{ |sum, el| sum + el }.to_f / arr.size
	end
	
end