FROM java:8-jre

ADD https://github.com/gitbucket/gitbucket/releases/download/4.10/gitbucket.war /opt/gitbucket.war

RUN ln -s /gitbucket /root/.gitbucket

VOLUME /gitbucket

ADD http://central.maven.org/maven2/org/codelibs/gitbucket/gitbucket-fess-plugin_2.12/1.0.0/gitbucket-fess-plugin_2.12-1.0.0.jar /root/.gitbucket/plugins/gitbucket-fess-plugin_2.12.jar

# Port for web page
EXPOSE 8080
# Port for SSH access to git repository (Optional)
EXPOSE 29418

ENTRYPOINT ["java", "-jar", "/opt/gitbucket.war"]
