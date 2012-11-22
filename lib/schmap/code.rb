module Schmap

  class Code
    
    #!@ method decode: return an hash ov values which is the map of the schmap code
    def self.decode(schmap_code)
      info = {}
      codes_array = schmap_code.scan(/.{3}/)
      codes_array.collect do |code|
        result = SchmapApi.codes[code]
        info.merge!(result["section"].to_s.downcase.gsub(" ", "_").gsub("/", "_").gsub("-", "").gsub("__", "_") => result["name"].to_s) if !result.nil?
      end
      return info
    end
    
    #!@ method code_to_value: return the code value
    def self.code_to_value(pcode)
      code = SchmapApi.codes[pcode]
      return code.nil? ? nil : code["name"]
    end
    
    def self.get_unique_keys
      optimized = JSON.parse(File.read(File.dirname(__FILE__) + "/../../data/optimized.json"))
      return optimized.map{|a| a[1]["section"].to_s.downcase.gsub(" ", "_").gsub("/", "_").gsub("-", "").gsub("__", "_") }.uniq
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