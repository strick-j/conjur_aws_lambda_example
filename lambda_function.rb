#!/usr/bin/env ruby

require 'aws-sdk-core'
require 'aws-sigv4'
require 'conjur-api'

def lambda_handler(event:, context:)

  # setup Conjur configuration object
  Conjur.configuration.account = "#{ENV["conjur_account"]}"
  Conjur.configuration.appliance_url = "https://#{ENV["conjur_master_hostname"]}"
  Conjur.configuration.authn_url = "#{Conjur.configuration.appliance_url}/authn-iam/#{ENV["authn_iam_service_id"]}"
  Conjur.configuration.cert_file = "#{ENV["conjur_cert_file"]}"
  Conjur.configuration.apply_cert_config!

  puts "---- Obtaining Authorization Header from STS"
  # Make a signed request to STS to get an authorization header
  header = Aws::Sigv4::Signer.new(
    service: 'sts',
    region: 'us-east-1',
    access_key_id: "#{ENV["AWS_ACCESS_KEY_ID"]}",
    secret_access_key: "#{ENV["AWS_SECRET_ACCESS_KEY"]}",
    session_token: "#{ENV['AWS_SESSION_TOKEN']}"
  ).sign_request(
    http_method: 'GET',
    url: 'https://sts.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15'
  ).headers

  puts "---- Authorization Header Obtained"
  puts "#{header}"
  puts "---- Authenticating host to awsconjur.strlab.us using signed Authorization Header"
  # Authenticate Conjur host identity using signed header in json format
  conjur = Conjur::API.new_from_key("#{ENV["conjur_authn_login"]}", header.to_json)
  puts "---- Retrieving conjur access token"
  # Get access token
  conjur.token
  puts "---- Conjur Token:"
  puts "#{conjur.token}"
  # Use the cached token to get the secrets
  variable_value = conjur.resource("#{Conjur.configuration.account}:variable:#{ENV["var_id"]}").value
  puts "---- Obtaining Secret Value for #{ENV["var_id"]}"
  puts "---- Conjur Secret Value: #{variable_value}"
  variable_value
end

