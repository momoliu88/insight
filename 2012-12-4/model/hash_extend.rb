class Hash
	def delete_invalid_entrys keywords,type
		self.each do |k,v|
			if type ==:value
				p = v
			else
				p = k
			end
			self.delete k if p==nil
      self.delete k if p&&p.empty? 
			keywords.each do |e|
				self.delete k if p&&(p.instance_of?String)&&(p.downcase.eql? e.downcase)
 			end 
    end
	end
end
