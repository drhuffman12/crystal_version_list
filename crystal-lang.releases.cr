require "json"

release_file_prefix = "crystal-lang.releases"

release_file_json = release_file_prefix + ".json"
release_file_csv = release_file_prefix + ".csv"

`curl https://api.github.com/repos/crystal-lang/crystal/releases > #{release_file_json}` unless File.file?(release_file_json)

# file = File.open(release_file_json)
contents = File.read(release_file_json)

json = JSON.parse(contents)

# json.each {|tag| puts [tag["tag_name"], tag["prerelease"], tag["published_at"], tag["zipball_url"], tag["body"]] }

File.open(release_file_csv, "w") do |f|
  f.print("version,release_date}\n")
  json.each {|tag| f.print("#{tag["tag_name"]},#{tag["published_at"]}\n") }
  f.flush
end
                                