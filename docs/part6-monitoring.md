1. Monitoring VM
   - monitoring
   - 192.168.57.30

2. Prometheus + Grafana
   - Docker Compose
   - Prometheus: port 9090
   - Grafana: port 3000

3. Node Exporter
   - jenkins     192.168.57.10:9100
   - agent01     192.168.57.11:9100
   - app01       192.168.57.20:9100
   - monitoring  192.168.57.30:9100

4. Grafana
   - Node Exporter Full dashboard
   - DevOps Demo Monitoring dashboard

5. Flask application metrics
   - /metrics endpoint
   - prometheus-client
   - devops_demo_http_requests_total

6. Prometheus application target
   - 192.168.57.20:8080
   - job: devops-demo

7. Alerting
   - DevOps Demo Down
   - query: up{job="devops-demo"}
   - condition: below 1
   - evaluation interval: 1m
   - pending period: 1m

8. Slack notification
   - Slack contact point
   - #jenkins-notifications
   - tested with docker stop/start

9. Recovery test
   - docker stop devops-demo
   - alert became Firing
   - Slack alert received
   - docker start devops-demo
   - alert returned to Normal