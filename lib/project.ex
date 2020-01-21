defmodule BaseSupervisor do
  use Supervisor
  def start_link(min, max) do
    Supervisor.start_link(__MODULE__,[min, max])
	end
  def init([min, max]) do

  n3 = trunc(div(max-min,1000))
    children = Enum.map(1..1000, fn(x)->
      n1= min+(x-1)*n3
      n2 = min+x*n3
      worker(Genmodule,[n1,n2],[id: x, restart: :transient])
		end)
		    supervise(children,strategy: :one_for_one)
  end
end

defmodule Project do

	def func(args \\ []) do
    options = [switches: [file: :string],aliases: [f: :file]]
      {_,ar2,_} = OptionParser.parse(args,options)

    min = String.to_integer(List.first(ar2))
    max = String.to_integer(List.last(ar2))
		ids = BaseSupervisor.start_link(min,max)
		child_id = Supervisor.which_children(elem(ids,1))
		list = Enum.map(child_id,fn(x)->
			Genmodule.get_vamp_fangs(elem(x,1))
		end)
    li = List.flatten(list)|>Enum.uniq()
    li = li--[[]]
    li = Enum.sort(li)
    Enum.each(li,fn(x)-> IO.puts x end)
  end
end



Project.func(System.argv)
