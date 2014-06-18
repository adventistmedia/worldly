module Worldly
  class Country
    Data = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data/countries.yml')) || {}

    attr_reader :data, :code

    def initialize(code)
      @code = code.to_s.upcase
      @data = symbolize_keys(Data[@code])
    end

    def name
      @data[:name]
    end

    def official_name
      @data[:official_name] || name
    end

    def alpha2
      @data[:alpha2]
    end

    def alpha3
      @data[:alpha3]
    end

    def country_code
      @data[:country_code]
    end

    def dialing_prefix
      @data[:dialing_prefix]
    end

    def format
      @data[:format] || "{{address1}}\n{{address2}}\n{{city}}\n{{country}}"
    end

    def has_field?(f)
      fields.key?(f)
    end

    def required_fields
      fields.select{|k,v| v[:required] }
    end

    def fields
      @fields ||= build_fields
    end

    def region_options
      regions.to_a.map{|r| [ r[1], r[0] ] }
    end

    def regions?
      @has_regions ||= File.exist?(region_file_path)
    end

    def regions
      @regions ||= (regions? ? YAML.load_file(region_file_path) : {})
    end

    class << self

      def new(code)
        if self.exists?(code)
          super
        end
      end

      def exists?(code)
        Data.key?(code.to_s.upcase)
      end

      def all
        Data.map{ |country, data| [data['name'], country] }.sort
      end

      def [](code)
        self.new(code.to_s.upcase)
      end
    end

    private

    def region_file_path
      File.join(File.dirname(__FILE__), '..', "data/regions/#{@code}.yaml")
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    def format_value(value)
      formatted_field = value.to_s.strip
      f.each do |f|
        case f.split(',').first
        when 'upcase'
          formatted_field.upcase!
        when 'split'
          m, separator, indexes = f.split(',')
          indexes.each do |index|
            formatted_field.insert(separator, index)
          end
        end
      end
      formatted_field
    end

    # all fields are required by default unless otherwise stated
    def build_fields
      if @data.key?(:fields)
        @data[:fields].each do |k,v|
          v[:required] = true unless v.key?(:required)
        end
      else
        {city: {label:'City', required: true} }
      end
    end

  end
end