FROM sebp/elk:792

# Elasticsearch plugins
ENV ES_HOME /opt/elasticsearch
WORKDIR ${ES_HOME}

# Logstash plugins
WORKDIR ${LOGSTASH_HOME}
COPY ./logstash /etc/logstash/conf.d
RUN gosu logstash bin/logstash-plugin install logstash-input-couchdb_changes

# Kibana plugins
WORKDIR ${KIBANA_HOME}
RUN gosu kibana bin/kibana-plugin install https://github.com/sivasamyk/logtrail/releases/download/v0.1.31/logtrail-7.9.2-0.1.31.zip
