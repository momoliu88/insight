class SortedArray < Array
  def initialize(*args, &sort_by)
    @sort_by = sort_by || Proc.new { |x,y| x <=> y }
      super(*args)
      sort! &sort_by
  end

  def insert(i, v)
      # The next line could be further optimized to perform a
      # binary search.
      insert_before = index(find { |x| @sort_by.call(x, v) == 1 })
      super(insert_before ? insert_before : -1, v)
  end

  def <<(v)
      insert(0, v)
  end

  alias push <<
  alias unshift <<
  ["collect!", "flatten!", "[]="].each do |method_name|
      module_eval %{
        def #{method_name}(*args)
          super
          sort! &@sort_by
        end
      }
  end

  def reverse!
      #Do nothing; reversing the array would disorder it.
  end
end
if __FILE__==$0
  a=SortedArray.new(["23","223","1"]){|x,y| x.length <=> y.length}
  a[0]="1000"
  p a
  a << "1523"
  p a
	p a.max
	end
