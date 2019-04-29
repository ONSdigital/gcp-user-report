#!/usr/bin/env ruby

require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'prawn'
require 'prawn/table'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'User Report'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
CURRENT_CUSTOMER = 'my_customer'.freeze
DATE_TIME_FORMAT = '%d %b %Y %H:%M'.freeze
PDF_FILE = 'gcp-user-report.pdf'.freeze

# The file token.yml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yml'.freeze
SCOPE = Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n#{url}"
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

response = service.list_users(customer: CURRENT_CUSTOMER,
                              order_by: 'email')

table_data = [['Email', 'Admin', '2FA Enabled', 'Suspended', 'Created', 'Last Login']]
response.users.each do |user|
  row_data = []
  row_data << user.primary_email
  row_data << (user.is_admin? ? 'Yes' : 'No')
  row_data << (user.is_enrolled_in2_sv? ? 'Yes' : 'No')
  row_data << (user.suspended? ? 'Yes' : 'No')
  row_data << user.creation_time.strftime(DATE_TIME_FORMAT)
  row_data << user.last_login_time.strftime(DATE_TIME_FORMAT)
  table_data << row_data
end

Prawn::Document.generate(PDF_FILE, page_layout: :landscape) do |pdf|
  pdf.font('Helvetica')

  # Heading.
  pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], width: pdf.bounds.width do
    pdf.text('GCP Users Report', align: :left, size: 20)
  end

  # Users table.
  pdf.table(table_data, header: true, row_colors: %w[ffffff f0f0f0]) do |table|
    table.row(0).background_color = '000000'
    table.row(0).text_color = 'ffffff'
    table.row(0).font_style = :bold
  end

  # Page numbers.
  options = { at: [pdf.bounds.right - 150, 0],
              width: 150,
              align: :right,
              start_count_at: 1 }
  pdf.number_pages 'page <page>', options
end
