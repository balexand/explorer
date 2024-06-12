ints_generator = fn max_num, transform ->
  Enum.map(0..max_num, fn _ -> transform.(:rand.uniform(200_000)) end)
end

lists_of_lists_of = fn max_num, generator ->
  Enum.map(0..max_num, fn _ -> generator.() end)
end

# inputs = %{
#   "small list of ints" => {:date, ints_generator.(1_000, &Function.identity/1)},
#   "medium list of ints" => {:date, ints_generator.(100_000, &Function.identity/1)},
#   "big list of ints" => {:date, ints_generator.(1_000_000, &Function.identity/1)},
#   "small list of dates w/ dtype" => {:date, ints_generator.(1_000, &Date.from_gregorian_days/1)},
#   "medium list of dates w/ dtype" =>
#     {:date, ints_generator.(100_000, &Date.from_gregorian_days/1)},
#   "big list of dates w/ dtype" =>
#     {:date, ints_generator.(1_000_000, &Date.from_gregorian_days/1)},
#   "small list of dates without dtype" =>
#     {nil, ints_generator.(1_000, &Date.from_gregorian_days/1)},
#   "medium list of dates without dtype" =>
#     {nil, ints_generator.(100_000, &Date.from_gregorian_days/1)},
#   "big list of dates without dtype" =>
#     {nil, ints_generator.(1_000_000, &Date.from_gregorian_days/1)}
# }
inputs = %{
  "list of lists of dates as ints" =>
    {{:list, :date},
     lists_of_lists_of.(1_000, fn ->
       ints_generator.(1_000, &Function.identity/1)
     end)},
  "list of lists of dates as dates" =>
    {{:list, :date},
     lists_of_lists_of.(1_000, fn ->
       ints_generator.(1_000, &Date.from_gregorian_days/1)
     end)},
  "list of lists of dates as dates without dtype" =>
    {nil,
     lists_of_lists_of.(1_000, fn ->
       ints_generator.(1_000, &Date.from_gregorian_days/1)
     end)}
}

Benchee.run(
  %{
    "old" => fn {dtype, list} -> Explorer.Series.from_list(list, dtype: dtype) end,
    "new" => fn {dtype, list} -> Explorer.Series.from_list_new(list, dtype: dtype) end
  },
  time: 60,
  memory_time: 2,
  inputs: inputs
)
