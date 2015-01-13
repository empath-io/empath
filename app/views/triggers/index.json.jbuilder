json.array!(@triggers) do |trigger|
  json.extract! trigger, :id, :name, :trigger_id, :triggertype_id
  json.url trigger_url(trigger, format: :json)
end
