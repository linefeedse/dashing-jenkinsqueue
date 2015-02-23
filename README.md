# dashing-jenkinsqueue
Display the current build queue in jenkins

# This is a work in progress

It uses the standard Dashing List widget

###Installation

Install Dashing (I use the Dashing Dockerimage viaplay/dashing)

Place the jenkinsqueue.rb job in dashboard/jobs/
Place the jenkinsqueue.erb dashboard in dashboard/dashboards/

###Configuration
Make a jenkins.yml file in dashboard/config with this (example) contents:
```
---
jenkins_uri: http://localhost:8080
jenkins_user: username
jenkins_password: passw0rd
jenkins_tzoffset: +0
```
