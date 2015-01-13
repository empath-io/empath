json.array!(@subjects) do |subject|
  json.extract! subject, :id, :experiment_id, :email, :phone_number
  json.url subject_url(subject, format: :json)
end
