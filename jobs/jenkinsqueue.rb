require "date"

# This is W-I-P. If it eats your Jenkins server, don't blame me!

config_file = File.dirname(File.expand_path(__FILE__)) + '/../config/jenkins.yml'
config = YAML::load(File.open(config_file))

JENKINS_URI = config['jenkins_uri']

JENKINS_AUTH = {
  'name' => config['jenkins_user'],
  'password' => config['jenkins_password']
}

SCHEDULER.every '10s' do

  json = getFromJenkins(JENKINS_URI + 'queue/api/json')

  buildqueue = Hash.new({ value: '' })

  bqueue = json['items']
  bqueue.each {
    |build|
    minute = DateTime.strptime(build['inQueueSince'].to_s,"%s").strftime("%R")
    shortdesc = ''
    build['actions'].each {
      |action|
      if action['causes'] then
        action['causes'].each {
          |cause|
          shortdesc += cause['shortDescription']
        }
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
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)

  json = JSON.parse(response.body)
  return json
end
