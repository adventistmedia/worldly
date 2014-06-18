module Worldly
  class Country
    Data = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data/countries.yml')) || {}

    attr_reader :data, :code

    def initialize(code)
      @code = code.to_s.upcase
      @data = Data[@code]
    end

    def name
      @data['name']
    end

    def alpha2
      @data['alpha2']
    end

    def alpha3
      @data['alpha3']
    end

    def country_code
      @data['country_code']
    end

    def dialing_prefix
      @data['dialing_prefix']
    end

    def format
      @data['format'] || "{{address1}}\n{{address2}}\n{{city}}\n{{country}}"
    end

    def fields
      symbolize_keys(@data['fields']) || {city: 'City'}
    end

    def has_field?(f)
      fields.key?(f)
    end

    def required_fields
      fields.keys - optional_fields
    end

    def optional_fields
      (@data['optional_fields'] || []).map(&:to_sym)
    end

    def all_fields(exclude_country=false)
      af = {
        address1: 'Address 1',
        address2: 'Address 2'
      }.merge(fields)
      af[:country] = 'Country' unless exclude_country
      af
    end

    def field_info
      @fields_data ||= fields.inject({}) do |hash,values|
        hash[values[0]] = {
          name: values[1],
          required: required_fields.include?(values[0]),
          options: field_options(values[0])
        }
        hash
      end
    end

    def field_options(f)
      f== :region && use_regions? ? regions.map{|r| [r[1],r[0]] } : []
    end

    def regions?
      @regions_exist ||= File.exist?(region_file_path)
    end

    def use_regions?
      has_field?(:region) && regions?
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
      hash ||= {}
      Hash[hash.map{ |k, v| [k.to_sym, v] }]
    end

  end
end