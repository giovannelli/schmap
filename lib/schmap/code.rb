module Schmap

  class Code
    
    #!@ method decode: return an hash ov values which is the map of the schmap code
    def self.decode(schmap_code)
      info = {}
      codes_array = schmap_code.scan(/.{3}/)
      codes_array.collect do |code|
        result = SchmapApi.codes[code]
        info.merge!(result["section"].to_s.downcase.gsub(" ", "_") => result["name"].to_s) if !result.nil?
      end
      return info
    end

    #!@ method prepare_codes: create an optimized file where the key is the schmap code
    def self.prepare_codes
      mycodes = {}
      response = JSON.parse(File.read(File.dirname(__FILE__) + "/../../data/codes.json"))
      response["sections_list"].collect do |item|
        section = item["section_name"]
        item["section_content"].collect do |section_content|
          mycodes.merge!({ section_content["code"] => {:name => section_content["name"], :section => section} })
        end
      end
      File.open(File.dirname(__FILE__) + "/../../data/optimized.json", "w+") do |f|
        f.write(JSON.pretty_generate(mycodes))
      end
    end
  end

end