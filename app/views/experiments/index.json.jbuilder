json.array!(@experiments) do |experiment|
  json.extract! experiment, :id, :name
  json.url experiment_url(experiment, format: :json)
end
