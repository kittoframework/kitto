use Kitto.Job.DSL

job :invalid, every: :minute do
  (str "this doesn't seem" "like Elixir")
end
