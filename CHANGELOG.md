# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - Unreleased

### Added
- `Cinema#latitude` and `Cinema#longitude` as Floats in decimal degrees, read from `cinemaLocationCoordinates` on the cinema's page like its address. They are `nil` when the page has no readable coordinates or they are 0, 0.

## [1.0.0] - 2026-10-22

### Added
- `VueUk::Cinema.all` and `VueUk::Cinema.new(id)` for Vue's UK cinemas, from the API behind myvue.com, with addresses read from each cinema's page.
- `VueUk::Performance.at(id, from:, to:)`, from one request per cinema, with booking links, audio language, subtitles, variants, film years and festivals, following cinebase 5.4.
- Hand-written fixtures, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
