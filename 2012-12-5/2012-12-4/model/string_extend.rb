class String
  def get_lastpart_name
    self[self.rindex(File::SEPARATOR)+1..-1]
  end
end
