Fabricator(:state) do
  name "Virginia"
  abbr "VA"
  country { Country.all.empty? ? Fabricate(:country) : Country.first }
end
