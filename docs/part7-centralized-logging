Centralized Logging Architecture
jenkins     ─┐
agent01     ─┤
app01       ─┼── Grafana Alloy ──> Loki ──> Grafana
monitoring  ─┘

app01 also collects Docker logs for:
container="devops-demo"

Useful Grafana queries to document:
{host="app01"}
{host="jenkins"}
{host="agent01"}
{host="monitoring"}
{container="devops-demo"}
{container="devops-demo"} |= "ERROR"

The failure-correlation result:
03:45:06  last application log
03:45:19  Docker/veth teardown events on app01
03:45:38  Prometheus alert condition active
~03:46     Slack DevopsDemoDown notification