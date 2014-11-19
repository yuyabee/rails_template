FROM yuyabee/centos-rails
MAINTAINER Yuya Yabe <yuyabee@gmail.com>

RUN yum -y install unzip
RUN npm install -g bower
RUN mkdir tempTest
ADD Gemfile ./tempTest/
WORKDIR tempTest
RUN bash -l -c 'bundle install --path vendor/bundle --without production'
ENV GUARD_GEM_SILENCE_DEPRECATIONS 1
RUN bash -l -c 'bundle exec rails new . --skip-bundle -T'
ADD app_template.rb ./app_template.rb
ENV TESTING_APP_TEMPLATE true
RUN bash -l -c 'bin/rake rails:template LOCATION=/app_template.rb'
RUN bash -l -c 'rm ./config/routes.rb'
ADD routes.rb ./tempTest/config/routes.rb
RUN bash -l -c 'bin/rails generate scaffold todo task:string done:boolean'
RUN bash -l -c 'bin/rake db:migrate'
RUN bash -l -c 'rm ./app/views/layouts/application.html.erb'
ADD application.html.slim ./tempTest/app/views/layouts/application.html.slim

EXPOSE 10000
CMD bash -l -c 'bundle exec rails server --port 10000'
