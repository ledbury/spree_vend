Fabricator(:option_value) do
  @value = Faker::HipsterIpsum.word
  name @value.parameterize
  presentation @value
  option_type
end

Fabricator(:option_type) do
  @type = Faker::HipsterIpsum.word
  name @type.parameterize
  presentation @type
end
