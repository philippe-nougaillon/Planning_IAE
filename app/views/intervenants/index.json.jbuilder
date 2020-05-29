json.array!(@intervenants) do |intervenant|
  json.extract! intervenant, :id, :nom
  json.url intervenant_url(intervenant, format: :json)
end
