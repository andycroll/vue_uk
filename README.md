# VueUk

A simple gem to pull cinemas and performances from the API behind the [Vue cinemas website](https://www.myvue.com) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'vue_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vue_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing language versions, years, screening dates and festival prefixes.

No token or setup is needed. The API answers uncached requests only within the
guest session the website starts for every visitor, so the gem starts one with
`POST /api/microservice/auth/token` and sends its cookies, starting a fresh one
once if the API rejects it.

### Cinema

Only UK cinemas are returned; Vue's euro-priced cinemas are left out. The API
has no addresses, so the first call to an address method reads the cinema's page
on myvue.com.

``` ruby
VueUk::Cinema.all
#=> [<VueUk::Cinema ...>, <VueUk::Cinema ...>, ...]

cinema = VueUk::Cinema.new(10051)
#=> <VueUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'The Viaduct',
  extended_address: 'Hyndburn Road',
  locality:         'Accrington',
  region:           nil,
  postal_code:      'BB5 1QF',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Vue'

cinema.full_name
#=> 'Vue Accrington'

cinema.id
#=> '10051'

cinema.url
#=> 'https://www.myvue.com/cinema/accrington'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. It makes one request
for all of the cinema's advertised dates and keeps those in the range.

``` ruby
VueUk::Performance.at(10051, from: Date.today, to: Date.today + 2)
#=> [<VueUk::Performance ...>, <VueUk::Performance ...>, ...]

performance = VueUk::Performance.at(10051).first
#=> <VueUk::Performance ...>

performance.film_name
#=> 'Clayface'

performance.language
#=> 'English' # Vue tags English audio too

performance.film_year
#=> nil # from the title, e.g. 2026 for 'Street Fighter (2026)'

performance.dimension
#=> '2d'

performance.variant
#=> ['audio_described']

performance.subtitled?
#=> false

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="CFF", year=2026>

performance.starting_at
#=> 2026-10-23 16:00:00 UTC

performance.booking_url
#=> 'https://www.myvue.com/book-tickets/summary/10051/HO00020288/139988'

performance.cinema_name
#=> 'Accrington'

performance.cinema_id
#=> '10051'
```

Variants are `arts`, `audio_described`, `autism_friendly`, `kids` and
`subtitled`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live myvue.com
```

Fixtures in `test/fixtures` are hand-written: invented films and addresses in
the shape of Vue's responses, never recorded output. `test/support/api_shapes.rb`
describes the fields the gem reads. The unit suite checks the fixtures against
it and the live suite checks real responses, held only in memory. When the API
changes, update the shape first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
