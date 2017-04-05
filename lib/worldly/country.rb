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

    def alpha2
      @data[:alpha2]
    end

    def alpha3
      @data[:alpha3]
    end

    def country_code
      @data[:country_code]
    end

    def address_format
      @data[:address_format] || "{{address1}}\n{{address2}}\n{{address3}}\n{{city}}\n{{region}} {{postcode}}\n{{country}}"
    end

    def all_fields
      [:address1, :address2, :address3, :country] + fields.keys
    end

    # Generate an address for printing based on the countries address format.
    # attributes = {address1: '12 hey St', address2: '', city: 'Homeville', postcode: 'AHZ 312' }
    # sending country = 'AU'. If added the country name will be excluded from address
    def to_print(attributes, sending_country=nil)
      # don't add country if sending from country
      unless sending_country.to_s.upcase == @code
        attributes.merge!({ country: name})
      end
      print = address_format.dup
      all_fields.each do |f|
        print.gsub!("{{#{f}}}", format_values(f, attributes[f].to_s) )
      end
      print.squeeze(' ')
      .gsub(/\A\s+\n|\n\s+|\s+\n\s+\Z/, "\n")
      .squeeze("\n")
      .strip
    end

    # Generate an address for printing based on the countries address format.
    # attributes = {address1: '12 hey St', address2: '', city: 'Homeville', postcode: 'AHZ 312' }
    # sending country = 'AU'. If added the country name will be excluded from address
    def to_display(attributes, sending_country=nil)
      # don't add country if sending from country
      unless sending_country.to_s.upcase == @code
        attributes.merge!({ country: name})
      end
      print = address_format.dup
      all_fields.each do |f|
        print.gsub!("{{#{f}}}", format_values(f, attributes[f].to_s, ignore_rules: ['upcase']) )
      end
      print.squeeze(' ')
      .gsub(/\A\s+\n|\n\s+|\s+\n\s+\Z/, "\n")
      .squeeze("\n")
      .strip
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

    def has_regions?(f)
      f == :region && regions?
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

      def all(field='name')
        Data.map{ |country, data| [data[field.to_s], country] }.sort{|x,y| x[0] <=> y[0] }
      end

      def country_code_options
        Data.map{ |country, data| data['country_code'] }.uniq.reject(&:empty?).sort{|x,y| x.to_i <=> y.to_i }
      end

      def [](code)
        self.new(code.to_s.upcase)
      end
    end

    private

    def region_file_path
      File.join(File.dirname(__FILE__), '..', "data/regions/#{@code}.yml")
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
    # Format a value e.g :region, 'NY'
    # apply any formatting rules
    #  - if rule fullname included change the region to it's full name - New York
    # options = ignore_rules: ['upcase']
    def format_values(field, value, options={})
      value = value.dup
      value.to_s.strip!
      if !fields.key?(field) || fields[field][:format].nil?
        return value
      end
      rules = fields[field][:format].dup
      # ignore rules
      if options[:ignore_rules]
        rules = rules - options[:ignore_rules]
      end
      # use fullname rather than abbreviated
      # fullname rule must be applied first!
      if rules.delete('fullname') && regions[value]
        value = regions[value]
      end
      # formatting
      rules.each do |rule|
        case rule
        when 'upcase'
          value.upcase!
        end
      end
      value
    end

    # all fields are required by default unless otherwise stated
    def build_fields
      if @data.key?(:fields)
        @data[:fields].each do |k,v|
          v[:required] = true unless v.key?(:required)
        end
      else
        {city: {label:'City', required: true}, region: {label: 'Province', required: false}, postcode: {label: 'Post Code', required: false} }
      end
    end

  end
end