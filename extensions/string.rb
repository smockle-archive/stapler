String.class_eval do
  def is_int
    return self.to_i.to_s == self
  end
  
  def is_range
    case
      when self.include?("...")
        a = self.split("...")
        return a.length == 2 && a[0].is_int && a[1].is_int
      when self.include?("..")
        a = self.split("..")
        return a.length == 2 && a[0].is_int && a[1].is_int
      else
        return false
    end
  end
  
  def to_range
    case
      when self.is_range && self.include?("...")
        return self.split("...").inject { |s, e| Range.new(s.to_i, e.to_i, true) }
      when self.is_range && self.include?("..")
        return self.split("..").inject { |s, e| Range.new(s.to_i, e.to_i) }
      else
        raise TypeError, "Cannot convert " + self + " to range."
    end
  end
end