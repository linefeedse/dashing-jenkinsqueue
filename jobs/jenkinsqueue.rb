require "date"

config_file = File.dirname(File.expand_path(__FILE__)) + '/../config/jenkins.yml'
config = YAML::load(File.open(config_file))

JENKINS_URI = config['jenkins_uri']
TZoff = config['jenkins_tzoffset']*3600

JENKINS_AUTH = {
  'name' => config['jenkins_user'],
  'password' => config['jenkins_password']
}

SCHEDULER.every '30s' do

  json = getFromJenkins(JENKINS_URI + 'queue/api/json')

  buildqueue = Hash.new({ value: '' })

  bqueue = json['items']
  bqueue.each {
    |build|
    minute = DateTime.strptime((build['inQueueSince']/1000+TZoff).to_i.to_s,"%s").strftime("%R")
    shortdesc = ''
    build['actions'].each {
      |action|
      if action['parameters'] then
        shortdesc += action['parameters'][0]['name'] + ':' + action['parameters'][0]['value']
      end
    }
    buildqueue[build['url']] = { label: build['task']['name']+' '+shortdesc, value: minute }
  }

  send_event('jenkinsqueue', { items: buildqueue.values })
end

def getFromJenkins(path)

  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  if ( path =~ /^https/ ) then
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)

  json = JSON.parse(response.body)
  return json
end
