json.array!(@operations) do |operation|
  json.extract! operation, :id, :name, :trigger_id, :operationtype_id
  json.url operation_url(operation, format: :json)
end
