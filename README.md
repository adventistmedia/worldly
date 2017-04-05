# Worldly

Worldly provides information on countries for the purpose of address formatting and local naming
Additional information on country phone number conventions is available.

The gem aims to be small with no dependencies.

## Installation

Add this line to your application's Gemfile:

    gem 'worldly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install worldly

## Usage

Worldly has a Country class which can be used to access address and telephone information for countries.

Get all countries:
```
  Worldly::Country.all  => [["Afghanistan", "AF"], ["Albania", "AL"], ["Algeria", "DZ"],....]
```
The all method also accepts a field name as a string. By default this is name. Options include: alpha2,alpha3,country_code
```
  Worldly::Country.all('alpha3')  => [["ABW", "AW"], ["AFG", "AF"], ["AGO", "AO"],....]
```
Check if a country exists?
```
  Worldly::Country.exists?('AU')  => true
```
Get a list of all country phone number codes unique and sorted. Note that many countries can use the same code. If you want a full list use Worldly::Country.all('country_code')
```
  Worldly::Country.country_code_options => ["1", "20", "211", "212", "213", "216",.....]
```
### Working with a Country

Retrieve a country using it's country code
```
  country = Worldly::Country['AU']  => #<Worldly::Country:0x007fa48239ee90 @code="AU", @data={:name=>"Australia", :alpha2=>"AU", :alpha3=>"AUS", :country_code=>"61", :fields=>{:city=>{:label=>"City", :format=>["upcase"]}, :region=>{:label=>"State", :format=>["upcase"]}, :postcode=>{:label=>"Post Code"}}, :address_format=>"{{address1}}\n{{address2}}\n{{city}} {{region}} {{postcode}}\n{{country}}"}>
```
```
  country.name => Australia
  country.code   => AU
  country.alpha2 => AU
  country.alpha3 => AUS
  country.country_code => 61
```
Worldly uses the address fields city, region & postcode. Address1, Address2 and Country are implied and hence not added. A call to country.fields will return the fields not implied that the country address uses.
```
  country.fields => {:city=>{:label=>"City", :format=>["upcase"], :required=>true}, :region=>{:label=>"State", :format=>["upcase"], :required=>true}, :postcode=>{:label=>"Post Code", :required=>true}}
```
Each field notes the following details:

1. Label: The fields name in the specific country. For example a postcode is called "Post Code" in Australia, "PIN code" in India and "Zip Code" in the US
2. Required: Whether the field is required
3. Format: format is an array or rules applied when displaying the address. Current address rules include
  * upcase: Change the field to uppercase
  * code: Used be regions. By default the regions full name is used when displaying otherwise the region code. For example 'NSW' is used rather than New South Wales for the Australia state.

Field Methods
```
  country.has_field?(:city) => true
  country.required_fields => {:city=>{:label=>"City", :format=>["upcase"], :required=>true}, :region=>{:label=>"State", :format=>["upcase"], :required=>true}, :postcode=>{:label=>"Post Code", :required=>true}}
```
To retrieve all fields including address1, address2 & country use
```
  country.all_fields => [:address1, :address2, :country, :city, :region, :postcode]
```
### Regions

Regions (State/Province) are provided for some countries in seperate YAML files

Check if a regions exist for country
```
  country.regions? => true
```
Check if a given field has regions. This can be useful when generating forms based on the country.
```
  country.has_regions?(:region) => true
  country.has_regions?(:city) => false
```
```
  country.region_options => [["Australian Capital Territory", "ACT"], ["New South Wales", "NSW"], ["Northern Territory", "NT"], ["Queensland", "QLD"], ["South Australia", "SA"], ["Tasmania", "TAS"], ["Victoria", "VIC"], ["Western Australia", "WA"]]
```

### Formatting an address for mailing or display

You can return the address formatting with liquid tags
```
  country.address_format  => "{{address1}}\n{{address2}}\n{{city}} {{region}} {{postcode}}\n{{country}}"
```

To have the address formatted correctly for mailing use to_print(attributes, sending_country=nil)
* attributes: takes a hash of field values. If a required field is not provided it will simple not display in the address.
* sending_country: a country code - if provided and the address country matches the sending_country the country field will not be shown. This is useful if generating mailing addresses to be sent by your home country where country field is not required.

```
  country.to_print({address1: '12 hey St', address2: '', postcode: '2000', city: 'Newtown', state:'NSW'})
  => "12 hey St\nNEWTOWN 2000\nAustralia"
  country.to_print({address1: '12 hey St', region:'NSW', postcode: '2000' }, 'AU')
  => "12 hey St\nNSW 2000"
```

There is also a to_display method which ignores certain address formatting rules:

```
  country.to_print({address1: '12 hey St', address2: '', postcode: '2000', city: 'Newtown', state:'NSW'})
  => "12 hey St\nNEWTOWN 2000\nAustralia"
  country.to_display({address1: '12 hey St', address2: '', postcode: '2000', city: 'Newtown', state:'NSW'})
  => "12 hey St\nNewtown 2000\nAustralia"
```

## Contributing

If you find a country with mission regions, or a country missing address formatting information you can create a issue ticket with corrections.

Thanks bro!

1. Fork it ( http://github.com/amnwebmaster/worldly/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
