# GCP User Report
A Ruby script that queries the [Google Directory API](https://developers.google.com/admin-sdk/directory/) to produce a PDF report listing all GCP users, whether they have two-factor authentication (2FA) enabled etc.

## Installation
* Ensure that [Ruby](https://www.ruby-lang.org/en/downloads/) is installed
* Install [Bundler](https://bundler.io/) using `gem install bundler`
* Install the RubyGems this script depends on using `bundle install`

## Running
Use `./user_report.rb` to generate the GCP users report (named _gcp-user-report.pdf_).

## Copyright
Copyright (C) 2019 Crown Copyright (Office for National Statistics)