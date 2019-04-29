# GCP User Report
A Ruby script that queries the [Google Directory API](https://developers.google.com/admin-sdk/directory/) to produce a PDF report listing all GCP users, whether they have two-factor authentication (2FA) enabled etc.

## Installation
* Ensure that [Ruby](https://www.ruby-lang.org/en/downloads/) is installed
* Install [Bundler](https://bundler.io/) using `gem install bundler`
* Install the RubyGems this script depends on using `bundle install`
* Follow [Step 1](https://developers.google.com/admin-sdk/directory/v1/quickstart/ruby) to download the client configuration (**credentials.json** and move it to the same directory as this repo)

## Running
Run `./user_report.rb` to generate the GCP users report (named **gcp-user-report.pdf**). You may be prompted to open an OAuth URL in a browser to approve the request and paste the generated token in the terminal window the script is running in. Note that this only has to be done once because the token will be cached in **token.yml** afterwards.

## Copyright
Copyright (C) 2019 Crown Copyright (Office for National Statistics)