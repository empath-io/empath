json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :type, :approved
  json.url organization_url(organization, format: :json)
end
