require "json"
require "http/client"

class GithubRepoVersionStats
  getter :org, :repo, :release_file_prefix, :release_file_json, :release_file_csv, :releases_json

  def initialize(@org : String, @repo : String)
    @release_file_prefix = "#{org}.#{repo}.releases"
    @release_file_json = "#{@release_file_prefix}.json"
    @release_file_csv = "#{@release_file_prefix}.csv"
  end

  def run
    get_releases
    store_releases(get_releases)
  end

  def get_releases_paged(page_num)
    # `curl https://api.github.com/repos/#{org}/#{repo}/releases?page=#{page_num}`

    url = "https://api.github.com/repos/#{org}/#{repo}/releases?page=#{page_num}"
    puts "url: '#{url}'"
        
    uri = URI.parse(url)
    response = HTTP::Client.get uri
    
    unless response.status_code == 200
      raise "\nError connecting to url: '#{url}'; response.status_code: #{response.status_code}, response.status_message: #{response.status_message}, response.body:\n#{response.body}\n\n"
    end
    
    response.body    
  end

  def get_releases : Array(JSON::Any)
    items_per_page = [] of Int32
    page_num = 0
    done = false
    releases_json = [] of JSON::Any
    while (!done)
      page_num += 1
      item_count = 0
      page_data = JSON.parse(get_releases_paged(page_num))
      page_data.each do |release|
        item_count += 1
        releases_json << release
        puts "page_num: '#{page_num}', item_count: '#{item_count}'"
        # puts "page_num: '#{page_num}', item_count: '#{item_count}', release: '#{release}'"
      end
      items_per_page << item_count unless (item_count == 0)
      done = (item_count == 0)
    end
    puts "done: '#{done}', items_per_page: '#{items_per_page}'"
    releases_json
  end

  def store_releases(releases_json : Array(JSON::Any))
    @releases_json = releases_json
    File.open(release_file_json, "w") do |f|
      f.print(releases_json)
      f.flush
    end

    File.open(release_file_csv, "w") do |f|
      f.print("version,release_date}\n")
      releases_json.each {|tag| f.print("#{tag["tag_name"]},#{tag["published_at"]}\n") }
      f.flush
    end
  end
end

r = GithubRepoVersionStats.new("crystal-lang", "crystal")
r.run
