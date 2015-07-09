require 'sinatra'
require 'json'
require_relative 'auth.rb'
require_relative 'models.rb'

API_BASE = '/api/1.0'
API_BASE_PROTECTED = "#{API_BASE}/protected"
API_ENDPOINT_FACTORIES = "#{API_BASE_PROTECTED}/factories"
API_ENDPOINT_AUTH = "#{API_BASE}/auth"

FOLDER_PUBLIC = File.join(File.dirname(__FILE__), '../client')


set(:public_folder, FOLDER_PUBLIC)


configure do
    mime_type :json, 'application/json'
end


before "#{API_BASE_PROTECTED}/*" do
    username = Auth.decode_token(env['HTTP_AUTHORIZATION'])
    if not username
        halt 401
    end
end


get '/' do
  send_file(File.join(FOLDER_PUBLIC, 'index.html'))
end


get API_ENDPOINT_AUTH do
    username = params['username']
    password = params['password']
    if not Auth.check(username, password)
        status 401
        return
    end
    content_type :json
    return JSON.generate({
        :token => Auth.encode_token(username)
    })
end


get API_ENDPOINT_FACTORIES do
    factories = []
    for f in Factory.all()
        factories << f.to_api_record()
    end
    content_type :json
    return JSON.generate(factories)
end


post API_ENDPOINT_FACTORIES do
    record = JSON.parse(request.body.read())
    if not record
        halt 401
    end

    f = Factory.new()
    f.update_from_api_record(record)
    f.save()

    content_type :json
    return JSON.generate(f.to_api_record())
end


get "#{API_ENDPOINT_FACTORIES}/:id" do |id|
    f = Factory.get(id)
    if not f
        halt 404
    end
    content_type :json
    return JSON.generate(f.to_api_record())
end


put "#{API_ENDPOINT_FACTORIES}/:id" do |id|
    f = Factory.get(id)
    if not f
        halt 404
    end

    record = JSON.parse(request.body.read())
    if not record
        halt 401
    end

    f.update_from_api_record(record)
    f.save()

    content_type :json
    return JSON.generate(f.to_api_record())
end


delete "#{API_ENDPOINT_FACTORIES}/:id" do |id|
    f = Factory.get(id)
    if not f
        halt 404
    end

    if not f.remove()
        halt 500
    end
end
